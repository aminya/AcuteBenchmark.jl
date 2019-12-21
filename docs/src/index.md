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
config = Funb( sin, [(-1,1)], [Float32, Float64], [100])
```

use benchmark! to run the benchmark:
```julia
using AcuteBenchmark

configs = FunbArray([
    Funb( sin, [(-1,1)],[Float32, Float64], [100] );
    Funb( atan, [(-1,1), (-1,1)],[Float32, Float64],[100, 100] );
    Funb( *, [(-1, 1), (-1, 1), (-1, 1)], [Float32, Float64], [(100,100), (100,100)] );
    ])

benchmark!(configs)
```


```@index
```

```@autodocs
Modules = [AcuteBenchmark]
```
