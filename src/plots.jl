using Plots, Colors, ColorTypes # for plotting

export bar, dimplot

################################################################
function invert(c::RGB, distinguish::Bool = false)
     cout = RGB{Float64}(1-c.r,1-c.g,1-c.b)
     if distinguish && cout == c #gray
         cout = RGB{Float64}(0,0,0)
     end
     return cout
end
################################################################
"""
    bar(config::StructArray{Funb}; uniqueType::Bool = false, dimAnnotation::Bool = true, uniqueDim::Bool = false)

Plots bars for each dimension set.

It is assumed that number of dimension sets are the same.

- To have a same color for the same types, set true as the 2nd argument.
- To turn off dimension annotations pass false as the 3rd argument.
- In case of unique dimensions pass true as 4th argument to print dimension in title instead.

# Examples
```julia
bar(configs)
bar(configs, uniqueType = true, dimAnnotation = false, uniqueDim = true)
```
"""
function bar(config::StructArray{Funb}; uniqueType::Bool = false, dimAnnotation::Bool = true, uniqueDim::Bool = false)

    mkpath("bar")

    local titleText

    numFun = length(config.fun)

    bar_width = numFun/3.0*0.2
    bar_text_font = Int64(bar_width*40)
    dim_text_font = Int64(bar_width*30)
    xticks_font = Int64(bar_width*5)

    if uniqueType
        uniqueTypes = uniqueflatten(config.types[:])
        numUniqueTypes =length(uniqueTypes)
        colors = distinguishable_colors(numUniqueTypes, [RGB(1,1,1)])
    end

    _, numDimsSets = numArgsDims(config.dims[1])

    for iDimSet = 1:numDimsSets
        plt = plot()  # different figure for different dims

        for iFun = 1:numFun

            fname = [string(config.fun[iFun])]

            for iType = 1:length(config.types[iFun])

                x = [(iFun-1)+(bar_width*(iType-1))]

                if uniqueType
                    iTypeUnique = findfirst(x -> x==config.types[iFun][iType], uniqueTypes)
                    fillcolor = colors[iTypeUnique]
                    type_text_color = invert(fillcolor, true)'

                    # labels
                    if iFun == 1
                        labels = string(uniqueTypes[iType])
                    else
                        labels = ""
                    end
                    legend = :topleft
                    barText = ""

                else
                    fillcolor = :auto
                    type_text_color = :black

                    barText = Plots.text(string(config.types[iFun][iType]), pointsize = bar_text_font, :center, rotation = 90, color = type_text_color )

                    labels = ""
                    legend = false
                end

                if uniqueDim
                    dimText = ""
                    titleText = "Dimension $(string(config[1].dims[iFun][1,iDimSet]))"
                else
                    if dimAnnotation
                        dimText = Plots.text(stringMatrix(config.dims[iFun][:,iDimSet]), pointsize = dim_text_font, :center)
                    else
                        dimText = ""
                    end
                    titleText = "Dimension set $iDimSet"
                end

                y = [config.median[iFun][iType][iDimSet]]
                # adding bar
                bar!(plt,
                    x,
                    y,
                    labels = labels,
                    legend = legend,
                    fillcolor = fillcolor,
                    bar_width = bar_width,
                    annotations = ([x, x], [y./2, y .+ bar_width/8], [barText, dimText]),
                    dpi = 600
                )
            end
        end

        xticks!(0:numFun-1, string.(config.fun), rotation = 70, fontsize = xticks_font)

        title!(titleText)
        ylabel!("Time [micro seconds]")
        if uniqueType
            filename = "bar/bench-dims-set$iDimSet-unique.png"
        else
            filename = "bar/bench-dims-set$iDimSet.png"
        end
        savefig(filename)
    end
end

bar(config::Funb; uniqueType::Bool = false, dimAnnotation::Bool = true, uniqueDim::Bool = false) = bar(FunbArray(config), uniqueType=uniqueType, dimAnnotation=dimAnnotation, uniqueDim = uniqueDim)

"""
    bar(config::Pair{StructArray{Funb}}; uniqueType::Bool = false, dimAnnotation::Bool = false, uniqueDim::Bool =false, configName::Pair{String,String} = "1" => "2")

Gets a pair of StructArrays and calculates relative speed of coresponding elements and plots them.

Uses the first element of the pair for the configurations and only uses runtimes from the 2nd element of the pair. The relative speed is calculated like this:

1st element runtimes / 2nd element runtimes

Give the configsets names as a pair for the ylabel.
```julia
bar(configs => configs, uniqueType = true, dimAnnotation = false, uniqueDim =true, "group 1" => "group 2")
```
"""
function bar(config::Pair{StructArray{Funb,T1,T2,T3}, StructArray{Funb,T1,T2,T3}}; uniqueType::Bool = false, dimAnnotation::Bool = false, uniqueDim::Bool =false, configName::Pair{String,String} = "1" => "2") where {T1,T2,T3}

    mkpath("bar")
    local titleText

    bar_width = 0.2
    bar_text_font = Int64(bar_width*40)
    dim_text_font = Int64(bar_width*30)
    xticks_font = Int64(bar_width*5)

    if uniqueType
        uniqueTypes = uniqueflatten(config[1].types[:])
        numUniqueTypes =length(uniqueTypes)
        colors = distinguishable_colors(numUniqueTypes, [RGB(1,1,1)])
    end

    numFun = length(config[1].fun)
    _, numDimsSets = numArgsDims(config[1].dims[1])

    for iDimSet = 1:numDimsSets
        plt = plot()  # different figure for different dims

        for iFun = 1:numFun

            fname = [string(config[1].fun[iFun])]

            for iType = 1:length(config[1].types[iFun])

                x = [(iFun-1)+(bar_width*(iType-1))]

                if uniqueType
                    iTypeUnique = findfirst(x -> x==config[1].types[iFun][iType], uniqueTypes)
                    fillcolor = colors[iTypeUnique]
                    type_text_color = invert(fillcolor, true)

                    # labels
                    if iFun == 1
                        labels = string(uniqueTypes[iType])
                    else
                        labels = ""
                    end
                    legend = :topleft
                    barText = ""
                else
                    fillcolor = :auto
                    type_text_color = :black

                    barText = Plots.text(string(config[1].types[iFun][iType]), pointsize = bar_text_font, :center, rotation = 90, color = type_text_color )

                    labels = ""
                    legend = false
                end

                if uniqueDim
                    dimText = ""
                    titleText = "Dimension $(string(config[1].dims[iFun][1,iDimSet]))"
                else
                    if dimAnnotation
                        dimText = Plots.text(stringMatrix(config[1].dims[iFun][:,iDimSet]), pointsize = dim_text_font, :center)
                    else
                        dimText = ""
                    end
                    titleText = "Dimension set $iDimSet"
                end

                y = [config[1].median[iFun][iType][iDimSet] / config[2].median[iFun][iType][iDimSet]]
                # adding bar
                bar!(plt,
                    x,
                    y,
                    labels = labels,
                    legend = legend,
                    fillcolor = fillcolor,
                    bar_width = bar_width,
                    annotations = ([x, x], [y./2, y .+ bar_width/8], [barText, dimText]),
                    dpi = 600
                )
            end
        end

        xticks!(0:numFun-1, string.(config[1].fun), rotation = 70, fontsize = xticks_font)

        title!(titleText)
        ylabel!("Relative Speed ($(configName[2])/$(configName[1]))")
        if uniqueType
            hline!([1], line=(4, :dash, 0.6, [:green]), labels = 1)
        end
        savefig("bar/bench-dims-set$iDimSet-relative.png")
    end
end

################################################################
"""
    dimplot(config::StructArray{Funb})

Shows runtime of a function for different dimension sets. The axes are logarithmic.

# Examples
```julia
configs2 = Funb( sin, [(-1,1)],[Float32, Float64], [10 20 30 40] );

benchmark!(configs2)

dimplot(configs2)
```
"""
function dimplot(config::StructArray{Funb})

mkpath("dimplot")

bar_width = 0.2
bar_text_font = Int64(bar_width*40)
dim_text_font = Int64(bar_width*30)
xticks_font = Int64(bar_width*5)

numFun = length(config.fun)
_, numDimsSets = numArgsDims(config.dims[1])

    for iFun = 1:numFun

        plt = plot()  # different figure for different dims

        fname = [string(config.fun[iFun])]

        for iType = 1:length(config.types[iFun])

            x = 1:numDimsSets
            xticks = string.(dropdims(flatten([config.dims[iFun][1,iDimSet] for iDimSet = 1:numDimsSets]), dims=1))
            y = [config.median[iFun][iType][iDimSet] for iDimSet = 1:numDimsSets]
            # adding bar
            plot!(plt,
                x,
                y,
                labels = string(config.types[iFun][iType]),
                legend = :bottomright,
                xscale = :log10,
                yscale = :log10,
                dpi = 600
            )
            xticks!(x, xticks, fontsize = xticks_font)
        end

        title!("$(fname[1])")
        xlabel!("Dimension")
        ylabel!("Time [micro seconds]")

        savefig("dimplot/bench-$(fname[1]).png")
    end
end

dimplot(config::Funb) = dimplot(FunbArray(config))

"""
    dimplot(config::Vector{StructArray{Funb}}, labels::Vector{String})

By passing a vector different benchmark sets can be grouped together to be shown in a single plot. The axes are logarithmic.

# Examples
```julia
dimplot([config1,config2, config3], ["group 1", "group 2", "group3"])
```
"""
function dimplot(config::Vector{StructArray{Funb,T1,T2,T3}}, labels::Vector{String}) where {T1,T2,T3}

mkpath("dimplot")
numLabels = length(config)

bar_width = 0.2
bar_text_font = Int64(bar_width*40)
dim_text_font = Int64(bar_width*30)
xticks_font = Int64(bar_width*5)

numFun = length(config[1].fun)
_, numDimsSets = numArgsDims(config[1].dims[1])

    for iFun = 1:numFun

        fname = [string(config[1].fun[iFun])]

        for iType = 1:length(config[1].types[iFun])

            plt = plot()  # different figure for different dims

            x = 1:numDimsSets
            xticks = string.(dropdims(flatten([config[1].dims[iFun][1,iDimSet] for iDimSet = 1:numDimsSets]), dims=1))

            for iLabel = 1:numLabels

                y = [config[iLabel].median[iFun][iType][iDimSet] for iDimSet = 1:numDimsSets]

                # adding bar
                plot!(plt,
                    x,
                    y,
                    # labels = string(config[1].types[iFun][iType]),
                    labels = labels[iLabel],
                    legend = :right,
                    xscale = :log10,
                    yscale = :log10,
                    dpi = 600
                )
                xticks!(x, xticks, fontsize = xticks_font)

            end

            title!("$(fname[1]) - Type $(config[1].types[iFun][iType])")
            xlabel!("Dimension")
            ylabel!("Time [micro seconds]")

            savefig("dimplot/bench-$(fname[1])-Type-$(config[1].types[iFun][iType]).png")
        end
    end
end
