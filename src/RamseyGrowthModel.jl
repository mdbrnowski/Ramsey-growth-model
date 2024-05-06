module RamseyGrowthModel

export GrowthModel

using Enzyme
using DataFrames
using Roots

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


function next_K_C(model::GrowthModel, K, C)::Tuple{Float64,Float64}
    u′(c::Float64) = autodiff(Reverse, model.u, Active, Active(c))[1][1]
    f′(k::Float64) = autodiff(Reverse, model.f, Active, Active(k))[1][1]

    next_K = model.f(K) + (1 - model.δ) * K - C
    next_K >= 0 || return NaN, NaN
    next_C = find_zero(x -> u′(x) - u′(C) / (model.β * (f′(next_K) + 1 - model.δ)), (0, Inf64))
    next_K, next_C
end

function shooting(model::GrowthModel, T::Int64, K₀::Float64, C₀::Float64)::DataFrame
    allocation = DataFrame(
        t=0:T,
        K=fill(NaN, T + 1),
        C=fill(NaN, T + 1)
    )
    allocation[1, "K"] = K₀
    allocation[1, "C"] = C₀
    for i ∈ 1:T
        Kₜ, Cₜ = next_K_C(model, allocation[i, "K"], allocation[i, "C"])
        if isnan(Cₜ)
            break
        end
        allocation[i+1, "K"], allocation[i+1, "C"] = Kₜ, Cₜ
    end
    allocation
end

function find_best_allocation(model::GrowthModel, T::Int64, K₀::Float64; tol::Float64=K₀/1e6)::DataFrame
    C_low, C_high = 0, model.f(K₀)

    # todo: add a loop failure exit after too many iterations
    # todo: log number of iterations before return
    while true
        C_mid = (C_low + C_high) / 2
        allocation = shooting(model, T, K₀, C_mid)
        next_K = next_K_C(model, last(allocation).K, last(allocation).C)[1]
        if isnan(next_K)
            C_high = C_mid
        elseif next_K > tol
            C_low = C_mid
        else
            return allocation
        end
    end
end

end # module RamseyGrowthModel
