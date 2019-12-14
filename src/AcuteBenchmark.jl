module AcuteBenchmark

using Distributions # for random input generation
# using BenchmarkTools # for benchmark
# using Plots # for plotting
# using JLD2, FileIO # to save file

# export DataFrame # from DataFrames
################################################################
# Vector Benchmark
# using DataFrames

function Distributions.Uniform(::Type{T}, a, b) where {T <: Real}
    return Uniform(T(a), T(b))
end

################################################################
"""
    BenchConfig(;functions, sets, dims)

# Arguments
- functions: vector of functions: Module.fun or :(Module.fun)
- limits
- types
- dims: vector of dimensions of the input vectors for each argument

Creates random inputs based on the number of inputs and the domain specified in funs
# Examples
```julia
config = BenchConfig(
    functions = [sin, atan, *],
    limits = [[(-1,1)], [(-1,1), (-1,1)], [(-1, 1), (-1, 1), (-1, 1)]],
    types = fill([Float32, Float64], (3)),
    dims = [ [1000], [1000, 1000], [(1000,1000), (1000,1000)] ],
)
```
"""
struct BenchConfig
    # public
    functions::Vector{Union{Function, Expr}}
    limits::Vector{Vector{NTuple{2, T}}} where {T}
    types::Vector{Vector{DataType}}
    dims::Vector{Vector{Union{Number, Tuple}}}
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

        numArgs  = length(dims[iFun])

        for iType = 1:numTypes

            inputs[iFun][iType] = NTuple{numArgs, Any}
            sets[iFun][iType] = Vector(undef, numArgs)

            for iArg = 1:numArgs

                sets[iFun][iType][iArg] = Uniform(types[iFun][iType], limits[iFun][iArg]...)

                inputs[iFun][iType][iArg] = rand(sets[iFun][iType][iArg], dims[iFun][iArg])
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
    benchmark
end

"""
    BenchResult(config::BenchConfig)

"""
function BenchResult(config::BenchConfig)
    # benchmark = Trial
    for (iFun, fun) in enumerate(config.functions)
        for (iType, type) in enumerate(config.types)
            inp = config.inputs[iFun][iType]
            benchmark[iFun][iType] = @benchmark $fun($inp...)
        end
    end
    return BenchResult(config.functions, config.types, config.dims, benchmark)
end

end
