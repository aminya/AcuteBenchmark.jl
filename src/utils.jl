################################################################
# used inside benchmarks.jl

include("distributions.jl")

################################################################
# used inside benchmarks.jl

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
# used inside plots.jl

flatten(A) =reduce(hcat, A)
uniqueflatten(A) =  unique(flatten(A))

function stringMatrix(A)
    sprint(Base.print_matrix, A)
end
