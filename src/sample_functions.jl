"""Returns CRRA (constant relative risk aversion) utility function u(c) with given γ."""
function sample_u(γ::Float64)::Function
    @assert 0 <= γ < 1
    u(c::Float64) = c ^ (1 - γ) / (1 - γ)
    u
end

"""Returns per-capita Cobb-Douglas production function f(k) with given A and α."""
function sample_f(A::Float64, α::Float64)::Function
    @assert 0 < α < 1
    @assert 0 < A
    f(K_t::Float64) = A * K_t ^ α
    f
end
