using AcuteBenchmark
using Test

cd(@__DIR__)
@testset "AcuteBenchmark.jl" begin
    
    configs = FunbArray([
        Funb( sin, [(-1,1)],[Float32, Float64], [10] );
        Funb( atan, [(-1,1), (-1,1)],[Float32, Float64],[10, 10] );
        Funb( *, [(-1, 1), (-1, 1), (-1, 1)], [Float32, Float64], [(10,10), (10,10)] );
        ])
        
    benchmark!(configs)

    # Test IO
    AcuteBenchmark.save("test.jld2", configs)
    configs_loaded = AcuteBenchmark.load("test.jld2")
    
    @test configs.fun == configs_loaded.fun
    @test configs.limits == configs_loaded.limits
    @test configs.types == configs_loaded.types
    @test configs.dims == configs_loaded.dims
    @test configs.sets == configs_loaded.sets
    @test configs.inputs == configs_loaded.inputs
    @test configs.results == configs_loaded.results
    @test configs.median == configs_loaded.median

    bar(configs)
    
    bar(configs, uniqueType=true)
    
    bar(configs => configs, uniqueType=true)
    
    bar(configs => configs, uniqueType=true, dimAnnotation=false, uniqueDim=true)
    
    configs2 = Funb( sin, [(-1,1)],[Float32, Float64], [10 30 50 100 200 500] );
    
    benchmark!(configs2)
    
    dimplot(configs2)
end
