module SampleFunctions

"""Utility function u(c) with given λ."""
function u(c, λ)
    @assert 0 <= λ < 1
    c ^ (1 - λ) / (1 - λ)
end

end # module SampleFunctions