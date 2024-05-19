using Documenter

push!(LOAD_PATH, "..")

using RamseyGrowthModel

makedocs(
    sitename = "RamseyGrowthModel.jl",
    format = Documenter.HTML(),
    modules = [RamseyGrowthModel]
)

deploydocs(
    repo = "https://github.com/mdbrnowski/Ramsey-growth-model"
)
