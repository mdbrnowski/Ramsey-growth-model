using Documenter

push!(LOAD_PATH, "..")

using RamseyGrowthModel

makedocs(
    sitename = "RamseyGrowthModel.jl",
    format = Documenter.HTML(ansicolor=true),
    modules = [RamseyGrowthModel]
)

deploydocs(
    repo = "github.com/mdbrnowski/Ramsey-growth-model.git"
)
