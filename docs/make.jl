using Documenter

push!(LOAD_PATH, "..")

using RamseyGrowthModel

makedocs(
    sitename = "RamseyGrowthModel.jl",
    format = Documenter.HTML(),
    modules = [RamseyGrowthModel]
)

deploydocs(
    repo = "github.com/mdbrnowski/Ramsey-growth-model.git"
)
