using AspectJulia
using Test

@testset "util.jl" begin

    ## TODO: Y

    @test AspectJulia.Nullable{Int} === Union{Int,Nothing}

    @test AspectJulia.getn(2, [1, 2, 3]) == 2
    @test AspectJulia.getn(4, [1, 2, 3]) === nothing
    @test AspectJulia.getn(1, (1, 2, 3)) == 1
    @test AspectJulia.getn(4, (1, 2, 3)) === nothing
    @test AspectJulia.getn(2)([1, 2, 3]) == 2
    @test AspectJulia.getn(4)([1, 2, 3]) === nothing
    @test AspectJulia.getn(1)((1, 2, 3)) == 1
    @test AspectJulia.getn(4)((1, 2, 3)) === nothing

    @test AspectJulia.flat([[1, 2, 3], [4, 5, 6]]) == [1, 2, 3, 4, 5, 6]
    @test AspectJulia.flat([1, 2, 3]) == [1, 2, 3]
    @test AspectJulia.flat([]) == []
    @test AspectJulia.flat(nothing) == []

    @test AspectJulia.conv_ary2str([1, 2, 3]) == "[1, 2, 3]"
    @test AspectJulia.conv_ary2str([]) == "[]"
    @test AspectJulia.conv_ary2str(nothing) == ""

    @test AspectJulia.conv_dict2str(Dict(:a => 1, :b => 2)) == "Dict(a => 1, b => 2)"
    @test AspectJulia.conv_dict2str(Dict()) == "Dict()"
    @test AspectJulia.conv_dict2str(nothing) == ""

    ## TODO: postwalk, prewalk

    ## TODO: shortname, veryshortname, export_macrowithalias

end

@testset "advice/advice.jl" begin

end
