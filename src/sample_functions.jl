"""Returns CRRA (constant relative risk aversion) utility function u(c) with given γ."""
function sample_u(γ::Real)::Function
    0 <= γ || throw(DomainError("γ should be grater than or equal to 0."))
    if γ == 1
        c -> log(c) + 1
    else
        c -> (c ^ (1 - γ) - 1) / (1 - γ) + 1
    end
end

"""Returns per-capita Cobb-Douglas production function f(k) with given A and α."""
function sample_f(A::Real, α::Real)::Function
    0 < α < 1 || throw(DomainError("α should be in range (0, 1)."))
    0 < A || throw(DomainError("A should grater than 0."))
    k -> A * k ^ α
end
