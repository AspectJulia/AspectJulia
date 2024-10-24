function listepath(st; workingdir::String=pwd())

  modifiedst = st |> pre_weave(workingdir, false)

  Y(f -> (ex, path, parent_ex, argindex) -> begin
    function donext(t::Nullable{ExprType})
      if isnothing(t)
        []
      else
        if !(t isa IgnoreNode)
          nextpath = path * "/" * to_path(t)
          paths = [nextpath]
        else
          nextpath = path
          paths = []
        end
        spaths = map(cn -> f(cn, path, parent_ex, argindex), t.siblings) |> flat
        cpaths = map(cn_wi -> f(cn_wi[2], nextpath, ex, cn_wi[1]), t.children) |> flat

        [paths..., spaths..., cpaths...]
      end
    end

    try
      v = extract(ex, parent_ex, argindex)
      if v isa Array
        map(donext, v) |> flat
      else
        donext(v)
      end
    catch e
      @info "Error: $ex"
      @info e
      []
    end
  end)(modifiedst, "", nothing, 1) |> unique
end
