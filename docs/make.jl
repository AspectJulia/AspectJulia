using AspectJulia
using Documenter

DocMeta.setdocmeta!(AspectJulia, :DocTestSetup, :(using AspectJulia); recursive=true)

makedocs(;
    modules=[AspectJulia],
    authors="Osamu Ishimura <oishimura@outlook.com> and contributors",
    sitename="AspectJulia.jl",
    format=Documenter.HTML(;
        canonical="https://hrontan.github.io/AspectJulia.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/hrontan/AspectJulia.jl",
    devbranch="main",
)
