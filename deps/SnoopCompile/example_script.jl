using AcuteBenchmark

exampledir = joinpath(dirname(dirname(@__DIR__)), "examples")

include("$exampledir/examples.jl")
