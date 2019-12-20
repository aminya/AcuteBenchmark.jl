module AcuteBenchmark

using Distributions # for random input generation
using BenchmarkTools # for benchmark
# using Plots # for plotting
# using JLD2, FileIO # to save file
# using DataFrames
################################################################
export BenchConfig, BenchResult

################################################################
function Distributions.Uniform(::Type{T}, a, b) where {T <: Real}
    return Uniform(T(a), T(b))
end

################################################################
"""
    BenchConfig(;functions, sets, dims)

Creates random inputs for functions based on limits, types, and dims specified. Each of these arguments is a vector. So to benchmark each function, there should be a coresponding row in each vector (functions, limits, types, dims).

# Arguments
- functions: vector of functions: Module.fun or :(Module.fun)
- limits: min and max of possible values
- types : type of elements
- dims: Array of dimensions of the input vectors for each argument. Each column is for a new set of sizes, and each row is for different input arguments.

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
```
"""
struct BenchConfig
    # public
    functions::Vector{Union{Function, Expr}}
    limits::Vector{Vector{NTuple{2, T}}} where {T}
    types::Vector{Vector{DataType}}
    dims::Vector{Array{Union{Number, Tuple}}}
    # private
    sets #::Vector{Vector{Vector{T}}} where {T<:Distribution} # vector of input sets for each function. Each set is an array of distributions
    inputs #::Vector{Vector{Vector{T}}} where {T}
end

function BenchConfig(; functions, limits, types, dims)

    numFun = length(functions)
    sets = Vector(undef, numFun) # [iFun][iType][iArgs]
    inputs = Vector(undef, numFun) # [iFun][iType][iArgs]

    for iFun = 1:numFun

        numTypes  = length(types[iFun])
        sets[iFun] = Vector(undef, numTypes)
        inputs[iFun] = Vector(undef, numTypes)

        for iType = 1:numTypes

            dimsDims = ndims(dims[iFun])
            dimsSize  = size(dims[iFun])

            if dimsDims == 1
                numArgs = dimsSize[1]
                numDims = 1
            elseif dimsDims == 2
                numArgs = dimsSize[1]
                numDims = dimsSize[2]
            end

            sets[iFun][iType] = Vector(undef, numArgs)

            inputs[iFun][iType] = Vector(undef, numDims)

            for iDim = 1:numDims

                inputs[iFun][iType][iDim] = Vector(undef, numArgs) # {Array{types[iFun][iType]}}

                for iArg = 1:numArgs
                    sets[iFun][iType][iArg] = Uniform(types[iFun][iType], limits[iFun][iArg]...)
                    inputs[iFun][iType][iDim][iArg] = convert.(types[iFun][iType], rand(sets[iFun][iType][iArg], dims[iFun][iArg, iDim]) )
                end
            end

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
