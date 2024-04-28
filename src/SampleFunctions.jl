module SampleFunctions

"""Utility function u(c) with given λ."""
function u(c::Float64, λ::Float64)::Float64
    @assert 0 <= λ < 1
    c ^ (1 - λ) / (1 - λ)
end

end # module SampleFunctions