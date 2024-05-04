"""Utility function u(c) with given γ."""
function u(c::Float64, γ::Float64)::Float64
    @assert 0 <= γ < 1
    c ^ (1 - γ) / (1 - γ)
end

"""Per-capita production function f(k) with given A and α."""
function f(K_t::Float64, A::Float64, α::Float64)::Float64
    @assert 0 < α < 1
    A * K_t ^ α
end
