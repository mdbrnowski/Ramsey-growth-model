module RamseyGrowthModel

export GrowthModel, solve

using DataFrames
using ForwardDiff
using Roots

include("sample_functions.jl")

"""
Defines a Ramsey Growth Model.

# Fields

* `β` - discount factor
* `δ` - depreciation rate on capital
* `u` - utility function
* `f` - production function

# Constructors
If you want to use a CRRA utility function and a Cobb-Douglas production function, use the constructor:

```julia
GrowthModel(β::Float64, δ::Float64, γ::Float64, α::Float64, A::Float64)
```

where `γ` is a parameter for [`sample_u`](@ref), and `α` and `A` are parameters for [`sample_f`](@ref).
"""
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
    u′(c::Float64) = ForwardDiff.derivative(model.u, c)
    f′(k::Float64) = ForwardDiff.derivative(model.f, k)

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


"""
Returns the best possible capital and consumption allocation (as a DataFrame).

```julia
solve(model::GrowthModel, T::Int64, K₀::Float64; kwargs...)
```

# Arguments

* `model` - previously defined growth model
* `T` - considered time horizon
* `K₀` - initial capital

# Keyword Arguments

The algorithm uses a binary search; if you want, you can override the default maximum number of iterations (`max_iter=1000`) or error tolerance (`tol=K₀/1e6`).
"""
function solve(model::GrowthModel, T::Int64, K₀::Float64; tol::Float64=K₀ / 1e6, max_iter::Int=1000)::DataFrame
    C_low, C_high = 0, model.f(K₀)
    for iter in 1:max_iter
        C_mid = (C_low + C_high) / 2
        allocation = shooting(model, T, K₀, C_mid)
        next_K = next_K_C(model, last(allocation).K, last(allocation).C)[1]
        if isnan(next_K)
            C_high = C_mid
        elseif next_K > tol
            C_low = C_mid
        else
            @info "The best allocation has been found after $iter iterations."
            return allocation
        end
    end

    throw(ArgumentError("Failed to converge. Try increasing `tol` or `max_iter`."))
end

end # module RamseyGrowthModel
