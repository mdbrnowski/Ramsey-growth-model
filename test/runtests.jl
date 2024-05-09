using RamseyGrowthModel, Test

@testset "sample functions" begin

    @test_throws DomainError RamseyGrowthModel.sample_u(-0.1)

    u₁ = RamseyGrowthModel.sample_u(0.5)
    @test u₁(1.0) === 1.0
    @test u₁(2.0) === 2 * sqrt(2) - 1
    @test u₁(4.0) === 3.0

    u₂ = RamseyGrowthModel.sample_u(0.0)
    @test u₂(1.0) === 1.0
    @test u₂(2.0) === 2.0
    @test u₂(4.0) === 4.0

    u₃ = RamseyGrowthModel.sample_u(1.0)
    @test u₃(1.0) === 1.0
    @test u₃(exp(1)) === 2.0

    @test_throws DomainError RamseyGrowthModel.sample_f(0.0, 0.5)
    @test_throws DomainError RamseyGrowthModel.sample_f(1.0, 0.0)
    @test_throws DomainError RamseyGrowthModel.sample_f(1.0, 1.0)

    f₁ = RamseyGrowthModel.sample_f(1, 0.5)
    @test f₁(0.0) === 0.0
    @test f₁(1.0) === 1.0
    @test f₁(2.0) === sqrt(2)
    @test f₁(4.0) === 2.0

    f₂ = RamseyGrowthModel.sample_f(3.5, 0.7)
    @test f₂(0.0) === 0.0
    @test f₂(1.0) === 3.5
    @test log(f₂(exp(1))) ≈ log(3.5) + 0.7
end
