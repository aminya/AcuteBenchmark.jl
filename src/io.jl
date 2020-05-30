using FileIO

"""
    save(file_name, config)

Save benchmark data
# Examples
```julia
AcuteBenchmark.save("benchmarkdata.jld2", config)
```
"""
function save(file_name::String, config::StructArray{Funb,T1,T2,T3}) where {T1,T2,T3}
    file_name_parts = split(file_name, '.')
    if length(file_name_parts) > 1 && file_name_parts[end] == "jld2"
        # ignore
    else
        # to make sure it is saved with correct format
        file_name = file_name * ".jld2"
    end
        
    # convert to array before saving
    configArray = Array(config)
    
    # Always save/load with configArray name
    FileIO.save(file_name, Dict("configArray"=>configArray))
end

"""
    load(file_name)

load benchmark data
# Examples
```julia
configs = AcuteBenchmark.load("benchmarkdata.jld2")
```
"""
function load(file_name::String)
    file_name_parts = split(file_name, '.')
    if length(file_name_parts) > 1 && file_name_parts[end] == "jld2"
        # ignore
    else
        # to make sure it is saved with correct format
        file_name = file_name * ".jld2"
    end
    # Always save/load with configArray name
    return FunbArray(FileIO.load(file_name)["configArray"])
end

################################################################
