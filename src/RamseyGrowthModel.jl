module RamseyGrowthModel

export GrowthModel

using Roots
using Enzyme

include("sample_functions.jl")

struct GrowthModel
    β::Float64   # discount factor
    δ::Float64   # depreciation rate on capital
    u::Function   # utility function
    f::Function   # production function
end

GrowthModel(
    β::Float64,
    δ::Float64,
    γ::Float64,  # coefficient of relative risk aversion
    α::Float64,  # return to capital per capita
    A::Float64   # technology
) = GrowthModel(β, δ, sample_u(γ), sample_f(A, α))

function next_k_c(model::GrowthModel, k, c)::Tuple{Float64, Float64}
    u′(c::Float64) = autodiff(Reverse, model.u, Active, Active(c))[1][1]
    f′(K_t::Float64) = autodiff(Reverse, model.f, Active, Active(K_t))[1][1]

    next_k = model.f(k) + (1 - model.δ) * k - c
    next_k >= 0 || error("Capital k is negative!")
    next_c = find_zero(x -> u′(x) - u′(c) / (model.β * (f′(next_k) + 1 - model.δ)), (0, Inf64))
    next_k, next_c
end

end # module RamseyGrowthModel
