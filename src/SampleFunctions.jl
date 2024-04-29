module SampleFunctions

"""Utility function u(c) with given γ."""
function u(c::Float64, γ::Float64)::Float64
    @assert 0 <= γ < 1
    c ^ (1 - γ) / (1 - γ)
end

end # module SampleFunctions
