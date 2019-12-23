```@meta
CurrentModule = AcuteBenchmark
```

# AcuteBenchmark


AcuteBenchmark allows you to benchmark functions that get Arrays as their input.

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
![bench-dims-set1](bench-dims-set1.png)

To have a same color for the same types use:
```julia
bar(configs, true)
```

![bench-dims-set1-unique](bench-dims-set1-unique.png)

To plot the relative speed, pass a pair of configs:
```julia
bar(configs => configs, true)
```
![bench-dims-set1-relative](test/bench-dims-set1-relative.png)

```@index
```

```@autodocs
Modules = [AcuteBenchmark]
```
