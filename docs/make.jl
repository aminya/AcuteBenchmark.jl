using AcuteBenchmark
using Documenter

makedocs(;
    modules=[AcuteBenchmark],
    authors="Amin Yahyaabadi",
    repo="https://github.com/aminya/AcuteBenchmark.jl/blob/{commit}{path}#L{line}",
    sitename="AcuteBenchmark.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://aminya.github.io/AcuteBenchmark.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/aminya/AcuteBenchmark.jl",
)
