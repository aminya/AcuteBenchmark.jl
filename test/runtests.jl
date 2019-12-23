using AcuteBenchmark
using Test

cd(@__DIR__)
@testset "AcuteBenchmark.jl" begin
    configs = FunbArray([
        Funb( sin, [(-1,1)],[Float32, Float64], [10] );
        Funb( atan, [(-1,1), (-1,1)],[Float32, Float64],[10, 10] );
        Funb( *, [(-1, 1), (-1, 1), (-1, 1)], [Float32, Float64], [(10,10), (10,10)] );
        ])
     
    # AcuteBenchmark.save("a.jld2",configs)
    # AcuteBenchmark.load("a.jld2","configs")

    benchmark!(configs)

    bar(configs)

    bar(configs, true)

    bar(configs => configs, true)

end
