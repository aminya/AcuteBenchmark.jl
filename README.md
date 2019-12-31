# AcuteBenchmark

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://aminya.github.io/AcuteBenchmark.jl/dev)
[![Build Status](https://travis-ci.com/aminya/AcuteBenchmark.jl.svg?branch=master)](https://travis-ci.com/aminya/AcuteBenchmark.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/aminya/AcuteBenchmark.jl?svg=true)](https://ci.appveyor.com/project/aminya/AcuteBenchmark-jl)


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
![bench-dims-set1](test/bench-dims-set1.png)

To have a same color for the same types use:
```julia
bar(configs, true)
```
![bench-dims-set1-unique](test/bench-dims-set1-unique.png)

To plot the relative speed, pass a pair of configs:
```julia
bar(configs => configs, true)
```
![bench-dims-set1-relative](test/bench-dims-set1-relative.png)

To plot how the function acts over different dimension sets:
```julia
configs2 = Funb( sin, [(-1,1)],[Float32, Float64], [10 20 30 40] );
benchmark!(configs2)
dimplot(configs2)
```
![bench-sin](test/bench-sin.png)