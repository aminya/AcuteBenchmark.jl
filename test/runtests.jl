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

    bar(configs, uniqueType=true)

    bar(configs => configs, uniqueType=true)

    bar(configs => configs, uniqueType=true, dimAnnotation=false, uniqueDim=true)

    configs2 = Funb( sin, [(-1,1)],[Float32, Float64], [10 30 50 100 200 500] );

    benchmark!(configs2)

    dimplot(configs2)
end
