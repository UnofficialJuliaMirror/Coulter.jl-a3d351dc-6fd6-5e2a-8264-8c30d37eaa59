using Coulter
using Base.Test
using Distributions
using KernelDensity

@testset "Loading" begin
    data = loadZ2("testdata/b_0_1.=#Z2", "blank")

    @test data.timepoint == DateTime(2017, 12, 22, 17, 46, 58)
    @test all(data.binheights .== 0.0)
end

@testset "Analysis" begin
    @testset "Peak-finding" begin
        # simplified example
        ys = fill(0.1, 20)
        ys[1] = 0.0
        ys[10] = 0.2
        ys[11] = 0.2
        ys[16] = 0.4
        ys[17] = 0.3
        ys[18] = 0.1
        ys[20] = 0.0
        xs = collect(1.0:20)

        @test all(Coulter._find_peaks(xs, ys, minx=0.0) .== [10.5, 16.0])

        # more realistic example
        dist = MixtureModel([Normal(8.2, 0.75), Normal(9.6, 0.5)], [0.6, 0.4])
        xs = linspace(7, 17, 400)
        ys = pdf.(dist, xs)

        srand(1234)
        sim_data = rand(dist, 10000)
        srand()

        kd_est = kde(volume.(sim_data))
        peaks = Coulter._find_peaks(collect(kd_est.x), kd_est.density, minx=0.0)
        @test all((peaks .- [289.325, 446.655]) .< 0.01)
    end
end

@testset "Misc" begin
    @test volume(0.0) == 0.0
    @test volume(10.0) ≈ 523.59878
end
