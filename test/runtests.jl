using RamseyGrowthModel, Test
using DataFrames

@testset verbose = true "RamseyGrowthModel" begin

    @testset "Sample functions" begin

        @test_throws DomainError RamseyGrowthModel.sample_u(-0.1)

        u₁ = RamseyGrowthModel.sample_u(0.5)
        @test u₁(1) === 1.0
        @test u₁(2.0) === 2 * sqrt(2) - 1
        @test u₁(4.0) === 3.0

        u₂ = RamseyGrowthModel.sample_u(0.0)
        @test u₂(1) === 1.0
        @test u₂(2.0) === 2.0
        @test u₂(4.0) === 4.0

        u₃ = RamseyGrowthModel.sample_u(1.0)
        @test u₃(1) === 1.0
        @test u₃(exp(1)) === 2.0

        @test_throws DomainError RamseyGrowthModel.sample_f(0.5, 0.0)
        @test_throws DomainError RamseyGrowthModel.sample_f(0.0, 1.0)
        @test_throws DomainError RamseyGrowthModel.sample_f(1.0, 1.0)

        f₁ = RamseyGrowthModel.sample_f(0.5, 1)
        @test f₁(0) === 0.0
        @test f₁(1) === 1.0
        @test f₁(2.0) === sqrt(2)
        @test f₁(4.0) === 2.0

        f₂ = RamseyGrowthModel.sample_f(0.7, 3.5)
        @test f₂(0) === 0.0
        @test f₂(1.0) === 3.5
        @test log(f₂(exp(1))) ≈ log(3.5) + 0.7
    end

    @testset "Model solving" begin
        model = GrowthModel(0.95, 0.02, 2.0, 0.3, 1)
        K₀ = 0.2
        info_pattern = r"^The best allocation has been found after \d+ iterations\.$"
        allocation = @test_logs (:info, info_pattern) solve(model, 20, K₀)

        @test allocation.K[begin] == K₀
        @test RamseyGrowthModel.next_K_C(model, allocation.K[end], allocation.C[end])[1] < K₀ * 1e-6

        @test_throws DomainError solve(model, 20, -100)
        @test_throws DomainError solve(model, 20, 0)
        @test_throws DomainError solve(model, -1, K₀)
        @test_throws DomainError solve(model, 0, K₀)
        @test_throws DomainError solve(model, 3.14, K₀)

        # check if both keyword arguments work
        @test (
            @test_logs (:info, info_pattern) solve(model, 20, K₀, tol=0.5, max_iter=12)
        ) isa DataFrame

        # check if all supported types work
        @test (
            @test_logs (:info, info_pattern) solve(GrowthModel(9 // 10, 5 // 100, 2, 4 // 10, 1), 20, 1)
        ) isa DataFrame

        @test_throws ArgumentError solve(model, 20, K₀, tol=1e-100)
        @test_throws ArgumentError solve(model, 20, K₀, max_iter=5)

        @testset "high initial capital" begin
            K₀ = 9.9
            model = GrowthModel(0.95, 0.02, 2.0, 0.3, 1)
            model_tech = GrowthModel(0.95, 0.02, 2.0, 0.3, 100)

            @test (
                @test_logs (:info, r"capital is very high") solve(model, 20, K₀)
            ) isa DataFrame

            @test (
                @test_logs (:info, info_pattern) solve(model, 200, K₀)  # longer time horizon
            ) isa DataFrame

            @test (
                @test_logs (:info, info_pattern) solve(model_tech, 20, K₀)  # better techonology
            ) isa DataFrame
        end

        @testset "infinite time" begin
            model = GrowthModel(0.95, 0.02, 2.0, 0.3, 1)
            
            @test_logs (:info, r"T specified as infinity;") (:info, info_pattern) solve(model, Inf, 3)
            @test_logs (:info, r"T specified as infinity;") (:info, r"capital is very high") solve(model, Inf, 100)

            @test_throws DomainError solve(model, -Inf, 3)
        end
    end

end
