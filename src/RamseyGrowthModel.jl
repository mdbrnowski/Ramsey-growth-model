module RamseyGrowthModel
using Enzyme
export solveRCK

function solveRCK(γ::Float64, β::Float64, δ::Float64, α::Float64, A::Float64)
    u(c::Float64) = SampleFunctions.u(c, γ)
    u′(c::Float64) = autodiff(Reverse, u, Active, Active(c))[1][1]
end

end # module RamseyGrowthModel
