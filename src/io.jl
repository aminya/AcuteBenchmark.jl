import JLD2, FileIO # to save file

"""
    save(filename, configs)

Save benchmark data
# Examples
```julia
save("benchmarkdata.jld2", configs)
```
"""
function save(filename::String, config::StructArray{Funb})
    JLD2.@save(filename, config)
end

function load(filename::String, varname::String = "config")
    FileIO.load(filename, varname)
end

################################################################
