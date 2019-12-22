module AcuteBenchmark

using StructArrays # for type definitions
using Distributions, Statistics # for random input generation
using BenchmarkTools # for benchmark
using Plots, Colors, ColorTypes # for plotting
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
numArgs, numDimsSets = numArgsDims(in)
```
"""
function numArgsDims(in)
    dimsDims = ndims(in)
    dimsSize  = size(in)
    if dimsDims == 1
        numArgs = dimsSize[1]
        numDimsSets = 1
    elseif dimsDims == 2
        numArgs = dimsSize[1]
        numDimsSets = dimsSize[2]
    end
    return numArgs, numDimsSets
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

            numArgs, numDimsSets = numArgsDims(dims)

            sets[iType] = Vector(undef, numArgs)
            inputs[iType] = Vector(undef, numDimsSets)

            results[iType] = Vector{BenchmarkTools.Trial}(undef, numDimsSets)
            median[iType] = Vector{Float64}(undef, numDimsSets)

            for iDimSet = 1:numDimsSets

                inputs[iType][iDimSet] = Vector(undef, numArgs) # {Array{types[iType]}}

                for iArg = 1:numArgs
                    sets[iType][iArg] = Uniform(types[iType], limits[iArg]...)
                    inputs[iType][iDimSet][iArg] = convert.(types[iType], rand(sets[iType][iArg], dims[iArg, iDimSet]) )
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

            numArgs, numDimsSets = numArgsDims(config.dims[iFun])

            for iDimSet = 1:numDimsSets
                inp = config.inputs[iFun][iType][iDimSet]

                println("Benchmarking $fun - $type - dimension set $iDimSet")

                if numArgs == 1 # single argument function
                    if hasmethod(fun, (typeof(inp[1]),)) # check if array method exists
                        config[iFun].results[iType][iDimSet] = @benchmark $fun($inp[1])
                    else # broadcast
                        config[iFun].results[iType][iDimSet] = @benchmark $fun.($inp[1])
                    end
                else
                    if hasmethod(fun, Tuple(typeof.(inp))) # check if array method exists
                        config[iFun].results[iType][iDimSet] = @benchmark $fun($inp...)
                    else # broadcast
                        config[iFun].results[iType][iDimSet] = @benchmark $fun.($inp...)
                    end
                end
                config[iFun].median[iType][iDimSet] = median(config[iFun].results[iType][iDimSet].times) / 1000 # micro seconds
            end
        end
    end
    return config
end

benchmark!(config::Array{Funb}) = benchmark!(FunbArray(config))
benchmark!(config::Funb) = benchmark!([config])

################################################################
#=
"""
    save(filename, configs)

Save benchmark data
# Examples
```julia
save("benchmarkdata.jld2", configs)
```
"""
function save(filename::String, config::StructArray{Funb})
    JLD2.@save filename config
end

function load(filename::String)
    FileIO.load(filename, "config")
end
=#
################################################################

flatten(A) =reduce(hcat, A)
uniqueflatten(A) =  unique(flatten(A))

function invert(c::RGB, distinguish::Bool = false)
     cout = RGB{Float64}(1-c.r,1-c.g,1-c.b)
     if distinguish && cout == c #gray
         cout = RGB{Float64}(0,0,0)
     end
     return cout
end
################################################################

function stringMatrix(A)
    sprint(Base.print_matrix, A)
end

################################################################
"""
    bardim(Main.configs, :fun)

Plots bars for each dimension set.

It is assumed that number of dimension sets are the same.

# Examples
```julia
bardim(configs)
```
"""
function bardim(config::StructArray{Funb})

    bar_width = 0.2
    bar_text_font = Int64(bar_width*40)
    dim_text_font = Int64(bar_width*30)
    xticks_font = Int64(bar_width*5)

    numFun = length(config.fun)
    _, numDimsSets = numArgsDims(config.dims[1])

    for iDimSet = 1:numDimsSets

        plt = plot()  # different figure for different dims

        for iFun = 1:numFun

            fname = [string(config.fun[iFun])]

            for iType = 1:length(config.types[iFun])

                x = [(iFun-1)+(bar_width*(iType-1))]

                barText = Plots.text(string(config.types[iFun][iType]), pointsize = bar_text_font, :center, rotation = 90 )

                dimText = Plots.text(stringMatrix(config.dims[iFun][:,iDimSet]), pointsize = dim_text_font, :center)


                    y = [config.median[iFun][iType][iDimSet]]
                    # adding bar
                    bar!(plt,
                        x,
                        y,
                        # labels = string(config.types[iFun][iType][iDimSet])[1],
                        legend = false,
                        bar_width = bar_width,
                        annotations = ([x, x], [y./2, y .+ bar_width/8], [barText, dimText]),
                        dpi = 600
                    )
            end
        end

        xticks!(0:numFun-1, string.(config.fun), rotation = 70, fontsize = xticks_font)

        title!("Benchmark")
        ylabel!("Time [micro seconds]")

        savefig("bench-dims-set$iDimSet.png")
    end
end


end
