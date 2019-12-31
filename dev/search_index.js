var documenterSearchIndex = {"docs":
[{"location":"index.html#","page":"Home","title":"Home","text":"CurrentModule = AcuteBenchmark","category":"page"},{"location":"index.html#AcuteBenchmark-1","page":"Home","title":"AcuteBenchmark","text":"","category":"section"},{"location":"index.html#","page":"Home","title":"Home","text":"AcuteBenchmark allows you to benchmark functions that get Arrays as their input.","category":"page"},{"location":"index.html#","page":"Home","title":"Home","text":"Creates random inputs for a function based on limits, types, and dims specified.","category":"page"},{"location":"index.html#","page":"Home","title":"Home","text":"config = Funb(\n    fun = sin,\n    limits = [(-1,1)],\n    types = [Float32, Float64],\n    dims = [100],\n)","category":"page"},{"location":"index.html#","page":"Home","title":"Home","text":"or just in a compact form:","category":"page"},{"location":"index.html#","page":"Home","title":"Home","text":"config = Funb( sin, [(-1,1)], [Float32, Float64], [10])","category":"page"},{"location":"index.html#","page":"Home","title":"Home","text":"use benchmark! to run the benchmark:","category":"page"},{"location":"index.html#","page":"Home","title":"Home","text":"using AcuteBenchmark\n\nconfigs = FunbArray([\n    Funb( sin, [(-1,1)],[Float32, Float64], [10] );\n    Funb( atan, [(-1,1), (-1,1)],[Float32, Float64],[10, 10] );\n    Funb( *, [(-1, 1), (-1, 1), (-1, 1)], [Float32, Float64], [(10,10), (10,10)] );\n    ])\n\nbenchmark!(configs)","category":"page"},{"location":"index.html#","page":"Home","title":"Home","text":"Plot the benchmark result using:","category":"page"},{"location":"index.html#","page":"Home","title":"Home","text":"bar(configs)","category":"page"},{"location":"index.html#","page":"Home","title":"Home","text":"(Image: bench-dims-set1)","category":"page"},{"location":"index.html#","page":"Home","title":"Home","text":"To have a same color for the same types use:","category":"page"},{"location":"index.html#","page":"Home","title":"Home","text":"bar(configs, true)","category":"page"},{"location":"index.html#","page":"Home","title":"Home","text":"(Image: bench-dims-set1-unique)","category":"page"},{"location":"index.html#","page":"Home","title":"Home","text":"To plot the relative speed, pass a pair of configs:","category":"page"},{"location":"index.html#","page":"Home","title":"Home","text":"bar(configs => configs, true)","category":"page"},{"location":"index.html#","page":"Home","title":"Home","text":"(Image: bench-dims-set1-relative)","category":"page"},{"location":"index.html#","page":"Home","title":"Home","text":"To plot how the function acts over different dimension sets:","category":"page"},{"location":"index.html#","page":"Home","title":"Home","text":"configs2 = Funb( sin, [(-1,1)],[Float32, Float64], [10 20 30 40] );\nbenchmark!(configs2)\ndimplot(configs2)","category":"page"},{"location":"index.html#","page":"Home","title":"Home","text":"(Image: bench-sin)","category":"page"},{"location":"index.html#","page":"Home","title":"Home","text":"","category":"page"},{"location":"index.html#","page":"Home","title":"Home","text":"Modules = [AcuteBenchmark]","category":"page"},{"location":"index.html#AcuteBenchmark.Funb","page":"Home","title":"AcuteBenchmark.Funb","text":"Funb(;fun, limits, types, dims)\n\nCreates random inputs for a function based on limits, types, and dims specified.\n\nArguments\n\nfunctions: function : Module.fun or :(Module.fun)\nlimits: min and max of possible values\ntypes : type of elements\ndims: Array of dimensions of the input vectors for each argument. Each column is for a new set of sizes, and each row is for different input arguments.\n\nExamples\n\nconfig = Funb(\n    fun = sin,\n    limits = [(-1,1)],\n    types = [Float32, Float64],\n    dims = [100],\n)\n\nor just in a compact form:\n\nconfig = Funb( sin, [(-1,1)], [Float32, Float64], [100])\n\n\n\n\n\n","category":"type"},{"location":"index.html#AcuteBenchmark.FunbArray-Tuple{Array{Funb,N} where N}","page":"Home","title":"AcuteBenchmark.FunbArray","text":"FunbArray\n\nArray of Funb configs for different functions.\n\nExamples\n\nusing AcuteBenchmark\n\nconfigs = FunbArray([\n    Funb( sin, [(-1,1)],[Float32, Float64], [100] );\n    Funb( atan, [(-1,1), (-1,1)],[Float32, Float64],[100, 100] );\n    Funb( *, [(-1, 1), (-1, 1), (-1, 1)], [Float32, Float64], [(100,100), (100,100)] );\n    ])\n\n\nYou can also directly give the configs in vectors:\n\nconfigs = FunbArray(\n    fun =   [sin,\n             atan,\n             *],\n    limits = [[(-1,1)],\n             [(-1,1), (-1,1)],\n             [(-1, 1), (-1, 1), (-1, 1)]],\n    types = fill([Float32, Float64], (3)),\n    dims = [ [100],\n             [100, 100],\n             [(100,100), (100,100)] ],\n)\n\n\n\n\n\n","category":"method"},{"location":"index.html#AcuteBenchmark.bar","page":"Home","title":"AcuteBenchmark.bar","text":"bar(config::StructArray{Funb}, uniqueType::Bool = false, annotations::Bool = true)\n\nPlots bars for each dimension set.\n\nIt is assumed that number of dimension sets are the same.\n\nTo have a same color for the same types, set true as the 2nd argument. To turn off annotations pass false as the 3rd argument.\n\nExamples\n\nbar(configs)\nbar(configs, true, true)\n\n\n\n\n\n","category":"function"},{"location":"index.html#AcuteBenchmark.bar-Union{Tuple{Pair{StructArrays.StructArray{Funb,T1,T2,T3},StructArrays.StructArray{Funb,T1,T2,T3}}}, Tuple{T3}, Tuple{T2}, Tuple{T1}, Tuple{Pair{StructArrays.StructArray{Funb,T1,T2,T3},StructArrays.StructArray{Funb,T1,T2,T3}},Bool}, Tuple{Pair{StructArrays.StructArray{Funb,T1,T2,T3},StructArrays.StructArray{Funb,T1,T2,T3}},Bool,Bool}} where T3 where T2 where T1","page":"Home","title":"AcuteBenchmark.bar","text":"bar(config::Pair{StructArray{Funb}}, uniqueType::Bool = false, annotations::Bool = false)\n\nGets a pair of StructArrays and calculates relative speed of coresponding elements and plots them.\n\nUses the first element of the pair for the configurations and only uses runtimes from the 2nd element of the pair. The relative speed is calculated like this:\n\n1st element runtimes / 2nd element runtimes\n\nbar(configs => configs, true, true)\n\n\n\n\n\n","category":"method"},{"location":"index.html#AcuteBenchmark.benchmark!-Tuple{StructArrays.StructArray{Funb,N,C,I} where I where C<:Union{Tuple, NamedTuple} where N}","page":"Home","title":"AcuteBenchmark.benchmark!","text":"benchmark!(config::StructArray{Funb}) # FunbArray{Funb}\nbenchmark!(config::Array{Funb})\n\nPerforms the benchmarking on a given Funb.\n\nExamples\n\nusing AcuteBenchmark\n\nconfigs = FunbArray([\n    Funb( sin, [(-1,1)],[Float32, Float64], [100] );\n    Funb( atan, [(-1,1), (-1,1)],[Float32, Float64],[100, 100] );\n    Funb( *, [(-1, 1), (-1, 1), (-1, 1)], [Float32, Float64], [(100,100), (100,100)] );\n    ])\n\nbenchmark!(configs)\n\n\n\n\n\n","category":"method"},{"location":"index.html#AcuteBenchmark.dimplot-Tuple{StructArrays.StructArray{Funb,N,C,I} where I where C<:Union{Tuple, NamedTuple} where N}","page":"Home","title":"AcuteBenchmark.dimplot","text":"dimplot(config::StructArray{Funb}, fungroup::Vector{Vector{String}})\n\nShows runtime of a function for different dimension sets. Functions can be grouped together to be shown in a single plot.\n\nExamples\n\nconfigs2 = Funb( sin, [(-1,1)],[Float32, Float64], [10 20 30 40] );\n\nbenchmark!(configs2)\n\ndimplot(configs2)\n\n\n\n\n\n","category":"method"},{"location":"index.html#AcuteBenchmark.numArgsDims-Tuple{Any}","page":"Home","title":"AcuteBenchmark.numArgsDims","text":"numArgsDims(in)\n\nFinding number of arguments and number of dimension sets\n\nExamples\n\nnumArgs, numDimsSets = numArgsDims(in)\n\n\n\n\n\n","category":"method"}]
}
