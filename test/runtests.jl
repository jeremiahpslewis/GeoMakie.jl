using GeoMakie, CairoMakie, Test

Makie.set_theme!(Theme(
    Heatmap = (rasterize = 5,),
    Image   = (rasterize = 5,),
    Surface = (rasterize = 5,),
))

@testset "Basics" begin
    lons = -180:180
    lats = -90:90
    field = [exp(cosd(l)) + 3(y/90) for l in lons, y in lats]

    fig = Figure()
    ax = GeoAxis(fig[1,1], coastlines=true)
    el = surface!(ax, lons, lats, field; shading = false)
    @test true
    # display(fig)
end

@testset "Examples" begin
    geomakie_path = dirname(dirname(pathof(GeoMakie)))
    examples = readdir(joinpath(geomakie_path, "examples"); join = true)
    filenames = filter(isfile, examples)
    filter!(endswith(".jl"), filenames)

    test_path = mkpath(joinpath(geomakie_path, "test_images"))
    cd(test_path) do
        for filename in filenames
            example_name = splitext(splitdir(filename)[2])[1]
            printstyled("Running ", bold = true, color = :cyan)
            println(example_name)

            @testset "$example_name" begin
                @test begin
                    print(rpad("Include: ", 9))
                    @time include(filename)
                    true
                end
                @test begin
                    savepath = "$example_name.png"
                    print(rpad("PNG: ", 9))
                    @time CairoMakie.save(savepath, Makie.current_figure(); px_per_unit=2);
                    isfile(savepath) && filesize(savepath) > 1000

                end
                @test begin
                    savepath = "$example_name.pdf"
                    print(rpad("PDF: ", 9))
                    @time CairoMakie.save(savepath, Makie.current_figure());
                    isfile(savepath) && filesize(savepath) > 1000
                end
                haskey(ENV, "CI") && rm("$example_name.pdf")
            end
        end
    end
end
