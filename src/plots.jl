using Plots, Colors, ColorTypes # for plotting

export bar
################################################################

flatten(A) =reduce(hcat, A)
uniqueflatten(A) =  unique(flatten(A))

function invert(c::RGB, distinguish::Bool = false)
     cout = RGB{Float64}(1-c.r,1-c.g,1-c.b)
     if distinguish && cout == c #gray
         cout = RGB{Float64}(0,0,0)
     end
     return cout
end
################################################################

function stringMatrix(A)
    sprint(Base.print_matrix, A)
end

################################################################
"""
    bar(config::StructArray{Funb}, uniqueType::Bool = false)

Plots bars for each dimension set.

It is assumed that number of dimension sets are the same.

To have a same color for the same types, set true as the 2nd argument

# Examples
```julia
bar(configs)
```
"""
function bar(config::StructArray{Funb}, uniqueType::Bool = false)

    bar_width = 0.2
    bar_text_font = Int64(bar_width*40)
    dim_text_font = Int64(bar_width*30)
    xticks_font = Int64(bar_width*5)

    if uniqueType
        uniqueTypes = uniqueflatten(config.types[:])
        numUniqueTypes =length(uniqueTypes)
        colors = distinguishable_colors(numUniqueTypes, [RGB(1,1,1)])
    end

    numFun = length(config.fun)
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
                    type_text_color = invert(fillcolor, true)
                else
                    fillcolor = :auto
                    type_text_color = :black
                end

                barText = Plots.text(string(config.types[iFun][iType]), pointsize = bar_text_font, :center, rotation = 90, color = type_text_color )

                dimText = Plots.text(stringMatrix(config.dims[iFun][:,iDimSet]), pointsize = dim_text_font, :center)


                y = [config.median[iFun][iType][iDimSet]]
                # adding bar
                bar!(plt,
                    x,
                    y,
                    # labels = string(config.types[iFun][iType][iDimSet])[1],
                    legend = false,
                    fillcolor = fillcolor,
                    bar_width = bar_width,
                    annotations = ([x, x], [y./2, y .+ bar_width/8], [barText, dimText]),
                    dpi = 600
                )
            end
        end

        xticks!(0:numFun-1, string.(config.fun), rotation = 70, fontsize = xticks_font)

        # title!("Benchmark")
        ylabel!("Time [micro seconds]")
        if uniqueType
            filename = "bench-dims-set$iDimSet-unique.png"
        else
            filename = "bench-dims-set$iDimSet.png"
        end
        savefig(filename)
    end
end

"""
    bar(config::Pair{StructArray{Funb}}, uniqueType::Bool = false)

Gets a pair of StructArrays and calculates relative speed of coresponding elements and plots them.

Uses the first element of the pair for the configurations and only uses runtimes from the 2nd element of the pair. The relative speed is calculated like this:

1st element runtimes / 2nd element runtimes
"""
function bar(config::Pair{StructArray{Funb,T1,T2,T3}, StructArray{Funb,T1,T2,T3}}, uniqueType::Bool = false) where {T1,T2,T3}

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
                else
                    fillcolor = :auto
                    type_text_color = :black
                end

                barText = Plots.text(string(config[1].types[iFun][iType]), pointsize = bar_text_font, :center, rotation = 90, color = type_text_color )

                dimText = Plots.text(stringMatrix(config[1].dims[iFun][:,iDimSet]), pointsize = dim_text_font, :center)


                y = [config[1].median[iFun][iType][iDimSet] / config[2].median[iFun][iType][iDimSet]]
                # adding bar
                bar!(plt,
                    x,
                    y,
                    # labels = string(config[1].types[iFun][iType][iDimSet])[1],
                    legend = false,
                    fillcolor = fillcolor,
                    bar_width = bar_width,
                    annotations = ([x, x], [y./2, y .+ bar_width/8], [barText, dimText]),
                    dpi = 600
                )
            end
        end

        xticks!(0:numFun-1, string.(config[1].fun), rotation = 70, fontsize = xticks_font)

        # title!("Benchmark")
        ylabel!("Relative Speed of 1/2")

        savefig("bench-dims-set$iDimSet-relative.png")
    end
end


        savefig("bench-dims-set$iDimSet.png")
    end
end
