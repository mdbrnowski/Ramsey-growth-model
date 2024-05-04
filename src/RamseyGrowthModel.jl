module RamseyGrowthModel
using Enzyme
export solveRCK

include("sample_functions.jl")

function solveRCK(γ::Float64, β::Float64, δ::Float64, α::Float64, A::Float64)
    u(c::Float64) = SampleFunctions.u(c, γ)
    f(K_t::Float64) = SampleFunctions.f(K_t, A, α)

    u′(c::Float64) = autodiff(Reverse, u, Active, Active(c))[1][1]
    f′(K_t::Float64) = autodiff(Reverse, f, Active, Active(K_t))[1][1]
end

end # module RamseyGrowthModel
