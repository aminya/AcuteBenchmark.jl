```@meta
CurrentModule = AcuteBenchmark
```

# AcuteBenchmark


AcuteBenchmark allows you to benchmark functions that get Arrays as their input.

# User packages
It is used inside [IntelVectorMath](https://github.com/JuliaMath/VML.jl) for benchmarking its functions.

Creates random inputs for a function based on limits, types, and dims specified.
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
config = Funb( sin, [(-1,1)], [Float32, Float64], [10])
```

use benchmark! to run the benchmark:
```julia
using AcuteBenchmark

configs = FunbArray([
    Funb( sin, [(-1,1)],[Float32, Float64], [10] );
    Funb( atan, [(-1,1), (-1,1)],[Float32, Float64],[10, 10] );
    Funb( *, [(-1, 1), (-1, 1), (-1, 1)], [Float32, Float64], [(10,10), (10,10)] );
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

![IntelVectorMath Performance Comparison](https://github.com/JuliaMath/VML.jl/raw/AcuteBenchmark/benchmark/bar/bench-dims-set4-relative.png)


To plot how the function acts over different dimension sets:
```julia
configs2 = Funb( sin, [(-1,1)],[Float32, Float64], [10 20 30 40] );
benchmark!(configs2)
dimplot(configs2)
```
![bench-sin](test/dimplot/bench-sin.png)


To compare different sets pass an array of configs:
```julia
dimplot([configsRealBase,configsRealIVM],["Base", "IntelVectorMath"])
```

![Performance over dimensions](https://github.com/JuliaMath/VML.jl/raw/AcuteBenchmark/benchmark/dimplot/bench-atan-Type-Float32.png)



```@index
```

```@autodocs
Modules = [AcuteBenchmark]
```
