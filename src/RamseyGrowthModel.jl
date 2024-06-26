module RamseyGrowthModel

export GrowthModel, solve, steady_state_K

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
where `γ` is a parameter for [`RamseyGrowthModel.sample_u`](@ref), and `α` and `A` are parameters for [`RamseyGrowthModel.sample_f`](@ref).

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
) = GrowthModel(Float64(β), Float64(δ), sample_u(γ), sample_f(α, A))


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

@doc raw"""
Returns steady state capital ``K``, to which capital ``K_t`` converges for large values of ``T``.

```julia
steady_state_K(model::GrowthModel)
```

# Arguments

* `model` - previously defined growth model

This value is mostly useful for plotting purposes and as a starting point of a simulation.
"""
function steady_state_K(model::GrowthModel)::Real
    f′(k::Real) = ForwardDiff.derivative(model.f, k)
    find_zero(x -> f′(x) - 1 / model.β + 1 - model.δ, (0, Inf64))
end

"""
Returns the best possible capital and consumption allocation (as a DataFrame).

```julia
solve(model::GrowthModel, T::Union{Integer,typeof(Inf)}, K₀::Real; kwargs...)
```

# Arguments

* `model` - previously defined growth model
* `T` - considered time horizon
* `K₀` - initial capital

Argument `T` should be of type `Integer` or equal to `Inf`. Passing a floating point value will raise an error.

# Keyword Arguments

The algorithm uses a binary search; if you want, you can override the default maximum number of iterations (`max_iter=1000`) or error tolerance (`tol=K₀/1e6`).
"""
function solve(model::GrowthModel, T::Union{Integer,typeof(Inf)}, K₀::Real; tol::Real=K₀ / 1e6, max_iter::Integer=1000)::DataFrame
    K₀ > 0 || throw(DomainError("Initial capital `K₀` should be positive."))
    T > 0 || throw(DomainError("Time horizon `T` should be positive."))
    T isa Integer || isinf(T) || throw(DomainError("Time horizon `T` should be an Integer or `Inf`."))
    C_low, C_high = 0, model.f(K₀)

    K_ter = 0

    if isinf(T)
        @info "T specified as infinity; setting T to 100 for calculation and plotting purposes."
        T = 100
        K_ter = steady_state_K(model)
    end

    if last(shooting(model, T + 1, K₀, C_high)).K > 0
        @info "Your initial capital is very high; the best allocation has been found using the highest possible initial consumption."
        return shooting(model, T, K₀, C_high)
    end

    for iter in 1:max_iter
        C_mid = (C_low + C_high) / 2
        allocation = shooting(model, T, K₀, C_mid)
        next_K = next_K_C(model, last(allocation).K, last(allocation).C)[1]

        error = next_K - K_ter

        if abs(error) < tol
            @info "The best allocation has been found after $iter iterations."
            return allocation
        elseif error > 0
            C_low = C_mid
        else
            C_high = C_mid
        end
    end

    throw(ArgumentError("Failed to converge. Try increasing `tol` or `max_iter`."))
end

end # module RamseyGrowthModel
