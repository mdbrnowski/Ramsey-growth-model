var documenterSearchIndex = {"docs":
[{"location":"#RamseyGrowthModel.jl","page":"RamseyGrowthModel.jl","title":"RamseyGrowthModel.jl","text":"","category":"section"},{"location":"#Defining-and-Solving-a-Growth-Model","page":"RamseyGrowthModel.jl","title":"Defining and Solving a Growth Model","text":"","category":"section"},{"location":"","page":"RamseyGrowthModel.jl","title":"RamseyGrowthModel.jl","text":"GrowthModel","category":"page"},{"location":"#RamseyGrowthModel.GrowthModel","page":"RamseyGrowthModel.jl","title":"RamseyGrowthModel.GrowthModel","text":"Defines a Ramsey Growth Model.\n\nFields\n\nβ - discount factor\nδ - depreciation rate on capital\nu - utility function\nf - production function\n\nConstructors\n\nIf you want to use a CRRA utility function and a Cobb-Douglas production function, use constructor\n\nGrowthModel(β::Real, δ::Real, γ::Real, α::Real, A::Real)\n\nwhere γ is a parameter for sample_u, and α and A are parameters for sample_f.\n\nHowever, if you have some other utility and production functions you want to use, constructor\n\nGrowthModel(β::Real, δ::Real, u::Function, f::Function)\n\nis also avaible.\n\n\n\n\n\n","category":"type"},{"location":"","page":"RamseyGrowthModel.jl","title":"RamseyGrowthModel.jl","text":"solve","category":"page"},{"location":"#RamseyGrowthModel.solve","page":"RamseyGrowthModel.jl","title":"RamseyGrowthModel.solve","text":"Returns the best possible capital and consumption allocation (as a DataFrame).\n\nsolve(model::GrowthModel, T::Integer, K₀::Real; kwargs...)\n\nArguments\n\nmodel - previously defined growth model\nT - considered time horizon\nK₀ - initial capital\n\nKeyword Arguments\n\nThe algorithm uses a binary search; if you want, you can override the default maximum number of iterations (max_iter=1000) or error tolerance (tol=K₀/1e6).\n\n\n\n\n\n","category":"function"},{"location":"#Sample-Functions-Used-in-the-Model","page":"RamseyGrowthModel.jl","title":"Sample Functions Used in the Model","text":"","category":"section"},{"location":"","page":"RamseyGrowthModel.jl","title":"RamseyGrowthModel.jl","text":"RamseyGrowthModel.sample_u","category":"page"},{"location":"#RamseyGrowthModel.sample_u","page":"RamseyGrowthModel.jl","title":"RamseyGrowthModel.sample_u","text":"Returns CRRA (constant relative risk aversion) utility function u(c) with a given γ.\n\nu(c) = fracc^1 - γ - 11 - γ + 1\n\nWhat does it look like? See for yourself here.\n\n\n\n\n\n","category":"function"},{"location":"","page":"RamseyGrowthModel.jl","title":"RamseyGrowthModel.jl","text":"RamseyGrowthModel.sample_f","category":"page"},{"location":"#RamseyGrowthModel.sample_f","page":"RamseyGrowthModel.jl","title":"RamseyGrowthModel.sample_f","text":"Returns per-capita Cobb-Douglas production function f(k) with given α and A.\n\nf(k) = A cdot k^α\n\n\n\n\n\n","category":"function"}]
}
