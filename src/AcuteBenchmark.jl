module AcuteBenchmark

using StructArrays # for type definitions
using Distributions # for random input generation
using BenchmarkTools # for benchmark
# using Plots # for plotting
# using JLD2, FileIO # to save file
# using DataFrames
################################################################
export Funb, FunbArray, BenchResult

################################################################
function Distributions.Uniform(::Type{T}, a, b) where {T <: Real}
    return Uniform(T(a), T(b))
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
    # private
    sets #::Vector{Vector{T}} where {T<:Distribution} # vector of input sets for each function. Each set is an array of distributions
    inputs #::Vector{Vector{T}} where {T}
end

Funb( fun, limits, types, dims) =  Funb( fun = fun, limits = limits, types = types, dims = dims)

function Funb(; fun, limits, types, dims)

        numTypes  = length(types)
        sets = Vector(undef, numTypes)
        inputs = Vector(undef, numTypes)

        for iType = 1:numTypes

            dimsDims = ndims(dims)
            dimsSize  = size(dims)

            if dimsDims == 1
                numArgs = dimsSize[1]
                numDims = 1
            elseif dimsDims == 2
                numArgs = dimsSize[1]
                numDims = dimsSize[2]
            end

            sets[iType] = Vector(undef, numArgs)

            inputs[iType] = Vector(undef, numDims)

            for iDim = 1:numDims

                inputs[iType][iDim] = Vector(undef, numArgs) # {Array{types[iType]}}

                for iArg = 1:numArgs
                    sets[iType][iArg] = Uniform(types[iType], limits[iArg]...)
                    inputs[iType][iDim][iArg] = convert.(types[iType], rand(sets[iType][iArg], dims[iArg, iDim]) )
                end
            end

        end

    return Funb( fun, limits, types, dims, sets, inputs)
end
    end
    return BenchConfig( functions, limits, types, dims, sets, inputs)
end

struct BenchResult
    # public
    functions::Vector{Union{Function, Expr}}
    types::Vector{Vector{DataType}}
    dims::Vector{Vector{Union{Number, Tuple}}}
    # private
    result
end

"""
    BenchResult(config::BenchConfig)

Performs the benchmarking on a given BenchConfig.

# Examples
```julia
using AcuteBenchmark

config = BenchConfig(
    functions = [sin,
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

BenchResult(config)
```
"""
function BenchResult(config::BenchConfig)

    numFuns = length(config.functions)
    result = Vector{Any}(undef, numFuns)
    # {BenchmarkTools.Trial}(undef, numFuns, numTypes, numDims)

    for (iFun, fun) in enumerate(config.functions)

        numTypes = length(config.types[iFun])
        result[iFun] = Vector{Any}(undef, numTypes)

        for (iType, type) in enumerate(config.types[iFun])

            dimsDims = ndims(config.dims[iFun])
            dimsSize  = size(config.dims[iFun])

            if dimsDims == 1
                numArgs = dimsSize[1]
                numDims = 1
            elseif dimsDims == 2
                numArgs = dimsSize[1]
                numDims = dimsSize[2]
            end

            result[iFun][iType] = Vector{BenchmarkTools.Trial}(undef, numDims)

            for iDim = 1:numDims
                inp = config.inputs[iFun][iType][iDim]

                println("Benchmarking $fun - $type - dimension set $iDim")
                if numArgs == 1 # single argument function
                    if hasmethod(fun, (typeof(inp[1]),)) # check if array method exists
                        result[iFun][iType][iDim] = @benchmark $fun($inp[1])
                    else # broadcast
                        result[iFun][iType][iDim] = @benchmark $fun.($inp[1])
                    end
                else
                    if hasmethod(fun, Tuple(typeof.(inp))) # check if array method exists
                        result[iFun][iType][iDim] = @benchmark $fun($inp...)
                    else # broadcast
                        result[iFun][iType][iDim] = @benchmark $fun.($inp...)
                    end
                end
            end
        end
    end
    return BenchResult(config.functions, config.types, config.dims, result)
end

end
