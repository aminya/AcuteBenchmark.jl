# AcuteBenchmark

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://aminya.github.io/AcuteBenchmark.jl/dev)
![Build Status (Github Actions)](https://github.com/aminya/AcuteBenchmark.jl/workflows/CI/badge.svg)

AcuteBenchmark allows you to benchmark functions that get Arrays as their input.

It is used inside [IntelVectorMath](https://github.com/JuliaMath/VML.jl) for benchmarking its functions. A fully working example available here: https://github.com/JuliaMath/VML.jl/blob/AcuteBenchmark/benchmark/benchmark.jl

Creates random inputs for a function based on limits, types, and dims specified.
```julia
config = Funb(
    fun = sin,
    limits = [(-1,1)],
    types = [Float32, Float64],
    dims = [10 100 200],
)
```
or just in a compact form:
```julia
config = Funb( sin, [(-1,1)], [Float32, Float64], [10 100 200])
```

* fun: the function `:fun` or :(Module.fun)
* limits: min and max of possible values
* types : type of elements
* dims:
  - each element gives the size of the input, and it is a:
     - Number (for 1D)
     - Tuple (for N-D)
  - each row for each function argument
  - each column for each dimension set.



use benchmark! to run the benchmark:
```julia
using AcuteBenchmark

configs = FunbArray([
    Funb( sin, [(-1,1)],[Float32, Float64], [10] );
    Funb( atan, [(-1,1), (-1,1)],[Float32, Float64],[10; 10] );
    Funb( *, [(-1, 1), (-1, 1), (-1, 1)], [Float32, Float64], [(10,10); (10,10)] );
    ])

benchmark!(configs)
```

Plot the benchmark result using:
```julia
bar(configs)
```
![bench-dims-set1](test/bar/bench-dims-set1.png)

To have a same color for the same types use:
```julia
bar(configs, uniqueType = true, dimAnnotation = true)
```
![bench-dims-set1-unique](test/bar/bench-dims-set1-unique.png)

To plot the relative speed, pass a pair of configs:
```julia
bar(configsRealBase => configsRealIVM, uniqueType = true, dimAnnotation = false, uniqueDim = true, "Base" => "IntelVectorMath")
```

![IntelVectorMath Performance Comparison](https://raw.githubusercontent.com/aminya/AcuteBenchmark-Results/master/IntelVectorMath/Real/bar/bench-dims-set6-relative.png)

To plot how the function acts over different dimension sets:
```julia
configs2 = Funb( sin, [(-1,1)],[Float32, Float64], [10 30 50 100 200 500] );
benchmark!(configs2)
dimplot(configs2)
```
The axes are logarithmic.

![bench-sin](test/dimplot/bench-sin.png)


To compare different sets pass an array of configs:
```julia
dimplot([configsRealBase,configsRealIVM],["Base", "IntelVectorMath"])
```

<!-- ![Performance over dimensions](https://github.com/JuliaMath/VML.jl/raw/AcuteBenchmark/benchmark/Real/dimplot/bench-atan-Type-Float32.png) -->


Use `AcuteBenchmark.save` and `AcuteBenchmark.load` to read and write the benchmark data.
```julia
AcuteBenchmark.save("test.jld2", configs)
configs_loaded = AcuteBenchmark.load("test.jld2")
```
