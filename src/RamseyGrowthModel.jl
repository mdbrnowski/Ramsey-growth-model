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
If you want to use a CRRA utility function and a Cobb-Douglas production function, use constructor
```julia
GrowthModel(β::Real, δ::Real, γ::Real, α::Real, A::Real)
```
where `γ` is a parameter for [`sample_u`](@ref), and `α` and `A` are parameters for [`sample_f`](@ref).

However, if you have some other utility and production functions you want to use, constructor
```julia
GrowthModel(β::Real, δ::Real, u::Function, f::Function)
```
is also avaible.

"""
struct GrowthModel{F_u<:Function,F_f<:Function}
    β::Float64    # discount factor
    δ::Float64    # depreciation rate on capital
    u::F_u        # utility function
    f::F_f        # production function
end

GrowthModel(
    β::Real,
    δ::Real,
    u::Function,
    f::Function,
) = GrowthModel(Float64(β), Float64(δ), u, f)

GrowthModel(
    β::Real,
    δ::Real,
    γ::Real,  # coefficient of relative risk aversion
    α::Real,  # return to capital per capita
    A::Real   # technology
) = GrowthModel(Float64(β), Float64(δ), sample_u(γ), sample_f(A, α))


function next_K_C(model::GrowthModel, K, C)::Tuple{Real,Real}
    u′(c::Real) = ForwardDiff.derivative(model.u, c)
    f′(k::Real) = ForwardDiff.derivative(model.f, k)

    next_K = model.f(K) + (1 - model.δ) * K - C
    next_K >= 0 || return NaN, NaN
    next_C = find_zero(x -> u′(x) - u′(C) / (model.β * (f′(next_K) + 1 - model.δ)), (0, Inf64))
    next_K, next_C
end

function shooting(model::GrowthModel, T::Integer, K₀::Real, C₀::Real)::DataFrame
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
solve(model::GrowthModel, T::Integer, K₀::Real; kwargs...)
```

# Arguments

* `model` - previously defined growth model
* `T` - considered time horizon
* `K₀` - initial capital

# Keyword Arguments

The algorithm uses a binary search; if you want, you can override the default maximum number of iterations (`max_iter=1000`) or error tolerance (`tol=K₀/1e6`).
"""
function solve(model::GrowthModel, T::Integer, K₀::Real; tol::Real=K₀ / 1e6, max_iter::Integer=1000)::DataFrame
    K₀ > 0 || throw(DomainError("Initial capital `K₀` should be positive."))
    T > 0 || throw(DomainError("Time horizon `T` should be positive."))
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
