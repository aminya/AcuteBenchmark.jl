module AcuteBenchmark

using StructArrays # for type definitions
using Distributions, Statistics # for random input generation
using BenchmarkTools # for benchmark
using Plots # for plotting
# import JLD2, FileIO # to save file
# using DataFrames
################################################################
export Funb, FunbArray, benchmark!, bardim

################################################################
function Distributions.Uniform(::Type{T}, a, b) where {T <: Real}
    return Uniform(T(a), T(b))
end

"""
    numArgsDims(in)
Finding number of arguments and number of dimension sets

# Examples
```julia
numArgs, numDims = numArgsDims(in)
```
"""
function numArgsDims(in)
    dimsDims = ndims(in)
    dimsSize  = size(in)
    if dimsDims == 1
        numArgs = dimsSize[1]
        numDims = 1
    elseif dimsDims == 2
        numArgs = dimsSize[1]
        numDims = dimsSize[2]
    end
    return numArgs, numDims
end
################################################################
"""
    Funb(;fun, limits, types, dims)

Creates random inputs for a function based on limits, types, and dims specified.

# Arguments
- functions: function : Module.fun or :(Module.fun)
- limits: min and max of possible values
- types : type of elements
- dims: Array of dimensions of the input vectors for each argument. Each column is for a new set of sizes, and each row is for different input arguments.

# Examples
```julia
config = Funb(
    fun = sin,
    limits = [(-1,1)],
    types = [Float32, Float64],
    dims = [100],
)
```
or just in a compact form:
```julia
config = Funb( sin, [(-1,1)], [Float32, Float64], [100])
```
"""
struct Funb

    # public
    fun::T where {T<:Function}
    limits::Vector{NTuple{2, T}} where {T}
    types::Vector{DataType}
    dims::Vector{T1} where {T1<:Union{T2, Tuple}} where {T2<:Number}

    # private - calculated

    sets #::Vector{Vector{T}} where {T<:Distribution} # vector of input sets for each function. Each set is an array of distributions
    inputs #::Vector{Vector{T}} where {T}

    results
    median
end

Funb( fun, limits, types, dims) =  Funb( fun = fun, limits = limits, types = types, dims = dims)

function Funb(; fun, limits, types, dims)

        numTypes  = length(types)
        sets = Vector(undef, numTypes)
        inputs = Vector(undef, numTypes)
        results = Vector{Any}(undef, numTypes)
        median = Vector{Any}(undef, numTypes)

        for iType = 1:numTypes

            numArgs, numDims = numArgsDims(dims)

            sets[iType] = Vector(undef, numArgs)
            inputs[iType] = Vector(undef, numDims)

            results[iType] = Vector{BenchmarkTools.Trial}(undef, numDims)
            median[iType] = Vector{Float64}(undef, numDims)

            for iDim = 1:numDims

                inputs[iType][iDim] = Vector(undef, numArgs) # {Array{types[iType]}}

                for iArg = 1:numArgs
                    sets[iType][iArg] = Uniform(types[iType], limits[iArg]...)
                    inputs[iType][iDim][iArg] = convert.(types[iType], rand(sets[iType][iArg], dims[iArg, iDim]) )
                end
            end

        end

    return Funb( fun, limits, types, dims, sets, inputs, results, median)
end
################################################################
"""
    FunbArray

Array of Funb configs for different functions.

# Examples
```julia
using AcuteBenchmark

configs = FunbArray([
    Funb( sin, [(-1,1)],[Float32, Float64], [100] );
    Funb( atan, [(-1,1), (-1,1)],[Float32, Float64],[100, 100] );
    Funb( *, [(-1, 1), (-1, 1), (-1, 1)], [Float32, Float64], [(100,100), (100,100)] );
    ])

```

You can also directly give the configs in vectors:
```julia
configs = FunbArray(
    fun =   [sin,
             atan,
             *],
    limits = [[(-1,1)],
             [(-1,1), (-1,1)],
             [(-1, 1), (-1, 1), (-1, 1)]],
    types = fill([Float32, Float64], (3)),
    dims = [ [100],
             [100, 100],
             [(100,100), (100,100)] ],
)
```
"""
FunbArray(configs::Array{Funb}) = StructArray(configs)

function FunbArray(;fun, limits, types, dims)

    numFun = length(fun)
    configs = Vector{Funb}(undef, numFun)

    for iFun = 1:numFun
        configs[iFun] = Funb(fun = fun[iFun], limits = limits[iFun], types = types[iFun], dims = dims[iFun])
    end

    return StructArray(configs)
end
################################################################
"""
    benchmark!(config::StructArray{Funb}) # FunbArray{Funb}
    benchmark!(config::Array{Funb})

Performs the benchmarking on a given Funb.

# Examples
```julia
using AcuteBenchmark

configs = FunbArray([
    Funb( sin, [(-1,1)],[Float32, Float64], [100] );
    Funb( atan, [(-1,1), (-1,1)],[Float32, Float64],[100, 100] );
    Funb( *, [(-1, 1), (-1, 1), (-1, 1)], [Float32, Float64], [(100,100), (100,100)] );
    ])

benchmark!(configs)
```
"""
function benchmark!(config::StructArray{Funb})

    numFuns = length(config.fun)

    for (iFun, fun) in enumerate(config.fun)

        numTypes = length(config.types[iFun])

        for (iType, type) in enumerate(config.types[iFun])

            numArgs, numDims = numArgsDims(config.dims[iFun])

            for iDim = 1:numDims
                inp = config.inputs[iFun][iType][iDim]

                println("Benchmarking $fun - $type - dimension set $iDim")

                if numArgs == 1 # single argument function
                    if hasmethod(fun, (typeof(inp[1]),)) # check if array method exists
                        config[iFun].results[iType][iDim] = @benchmark $fun($inp[1])
                    else # broadcast
                        config[iFun].results[iType][iDim] = @benchmark $fun.($inp[1])
                    end
                else
                    if hasmethod(fun, Tuple(typeof.(inp))) # check if array method exists
                        config[iFun].results[iType][iDim] = @benchmark $fun($inp...)
                    else # broadcast
                        config[iFun].results[iType][iDim] = @benchmark $fun.($inp...)
                    end
                end
                config[iFun].median[iType][iDim] = median(config[iFun].results[iType][iDim].times) / 1000 # micro seconds
            end
        end
    end
    return config
end

benchmark!(config::Array{Funb}) = benchmark!(FunbArray(config))
benchmark!(config::Funb) = benchmark!([config])

                    xticks!(1:length(fns)+1, fname, rotation = 70, fontsize = 10)
                    title!("VML Performance for array of size $NVALS")
                    ylabel!("Relative Speed (VML/Base)")
                    hline!([1], line=(4, :dash, 0.6, [:green]), labels = 1)
                    savefig("performance$(complex ? "_complex" : "").png")

                end
            end
        end

    elseif xvariable == :dims

    end

end

end
