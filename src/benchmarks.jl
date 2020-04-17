using StructArrays # for type definitions
using Statistics # for random input generation
using BenchmarkTools # for benchmark
# using DataFrames
using GFlops # to count gflops
using Suppressor

export Funb, FunbArray, benchmark!

################################################################
"""
    Funb(;fun, limits, types, dims)

Creates random inputs for a function based on limits, types, and dims specified.

# Arguments
- fun: the function `:fun` or :(Module.fun)
- limits: min and max of possible values
- types : type of elements
- dims: Array of dimensions of the input vectors for each argument. Each column is for a new set of sizes, and each row is for different input arguments. So:
     - each element gives the size of the input, and it is a:
        - Number (for 1D)
        - Tuple (for N-D)
     - each row for each function argument
     - each column for each dimension set


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
    limits::Vector{Tuple{T1,T2}} where {T1,T2}
    types::Vector{DataType}
    dims::VecOrMat{T1} where {T1<:Union{T2, Tuple}} where {T2<:Number}

    # private - calculated

    sets #::Vector{Vector{T}} where {T<:Distribution} # vector of input sets for each function. Each set is an array of distributions
    inputs #::Vector{Vector{T}} where {T}
    results
    median

    gflops
end

Funb( fun, limits, types, dims) =  Funb( fun = fun, limits = limits, types = types, dims = dims)

function Funb(; fun, limits, types, dims)

        numTypes  = length(types)
        sets = Vector(undef, numTypes)
        inputs = Vector(undef, numTypes)
        results = Vector{Any}(undef, numTypes)
        median = Vector{Any}(undef, numTypes)
        gflops = Vector{Any}(undef, numTypes)

        for iType = 1:numTypes

            numArgs, numDimsSets = numArgsDims(dims)

            sets[iType] = Vector(undef, numArgs)
            inputs[iType] = Vector(undef, numDimsSets)

            results[iType] = Vector{BenchmarkTools.Trial}(undef, numDimsSets)
            median[iType] = Vector{Float64}(undef, numDimsSets)
            gflops[iType] = Vector{Float64}(undef, numDimsSets)

            for iDimSet = 1:numDimsSets

                inputs[iType][iDimSet] = Vector(undef, numArgs) # {Array{types[iType]}}

                for iArg = 1:numArgs
                    try
                        sets[iType][iArg] = Uniform2(types[iType], limits[iArg]...)
                        inputs[iType][iDimSet][iArg] = Base.rand(sets[iType][iArg], dims[iArg, iDimSet])
                    catch
                        sets[iType][iArg] = Uniform(types[iType], limits[iArg]...)
                        inputs[iType][iDimSet][iArg] = Base.rand(sets[iType][iArg], dims[iArg, iDimSet])
                    end
                end
            end

        end

    return Funb( fun, limits, types, dims, sets, inputs, results, median, gflops)
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
FunbArray(configs::Funb) = StructArray([configs])

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

            numArgs, numDimsSets = numArgsDims(config.dims[iFun])

            for iDimSet = 1:numDimsSets
                inp = config.inputs[iFun][iType][iDimSet]

                println("Benchmarking $fun - $type - dimension set $iDimSet")

                if numArgs == 1 # single argument function
                    if hasmethod(fun, (typeof(inp[1]),)) # check if array method exists
                        config[iFun].results[iType][iDimSet] = @benchmark $fun($inp[1])

                        # counting gflops
                        @suppress config[iFun].gflops[iType][iDimSet] = @gflops $fun($inp[1])

                    else # broadcast
                        config[iFun].results[iType][iDimSet] = @benchmark $fun.($inp[1])

                        # counting gflops - TODO
                        @suppress config[iFun].gflops[iType][iDimSet] = length(inp[1]) * @gflops $fun($inp[1][1])
                    end
                else
                    if hasmethod(fun, Tuple(typeof.(inp))) # check if array method exists
                        config[iFun].results[iType][iDimSet] = @benchmark $fun($inp...)

                        # counting gflops
                        @suppress config[iFun].gflops[iType][iDimSet] = @gflops $fun($inp...)
                    else # broadcast
                        config[iFun].results[iType][iDimSet] = @benchmark $fun.($inp...)

                        # counting gflops - TODO
                        inp1dim = zeros(config[iFun].types[iType], numArgs)
                        for iArg = 1:numArgs
                            inp1dim[iArg] = Base.rand(config[iFun].sets[iType][iArg])
                        end
                        @suppress config[iFun].gflops[iType][iDimSet] = length(inp[1]) * @gflops $fun($inp1dim...)
                    end
                end
                config[iFun].median[iType][iDimSet] = median(config[iFun].results[iType][iDimSet].times) / 1000 # micro seconds

            end
        end
    end
    return config
end

benchmark!(config::Union{Funb, Array{Funb}}) = benchmark!(FunbArray(config))
