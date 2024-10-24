function weaver(aspect::Aspect)
  (st) -> begin
    xpath = to_xpath(aspect.pointcut)

    pathlist = findpath(st, xpath)

    Y(f -> (ex, upper_path, parent_ex, argindex) -> begin

      function donext(t::Nullable{ExprType}, t_ex)

        if isnothing(t)
          return t_ex
        end

        current_path = (t isa IgnoreNode) ? upper_path : upper_path * "/" * to_path(t)

        exhead = t_ex |> ex_head
        exargs = t_ex |> ex_args

        if current_path in pathlist
          if Meta.isexpr(t_ex, :aj)
            Expr(:aj, appendadviceinfo!(t_ex.args[1], aspect.advices, aspect.pointcut, to_jpparm(t)), exhead, exargs...)
          else
            Expr(:aj, AdviceInfoSet(aspect.advices, aspect.pointcut, to_jpparm(t)), exhead, exargs...)
          end
        elseif any(path -> startswith(path, current_path), pathlist)
          Expr(exhead, map(a_wi -> f(a_wi[2], current_path, ex, a_wi[1]), exargs |> enumerate)...)
        else
          t_ex
        end
      end

      v = extract(ex, parent_ex, argindex)

      if v isa Array
        for t in v
          ex = donext(t, ex)
        end
      else
        ex = donext(v, ex)
      end

      ex

    end)(st, "", nothing, 1)
  end
end

const aj_macros_to_expand = [Symbol("@attr")]


@inline function static_solve_include(expr, dir)
  postwalk(expr) do e
    if Meta.isexpr(e, :call) && e.args[1] == :include && e.args[2] isa String
      # if e.args[2] is relative path, join it with dir
      if isabspath(e.args[2])
        path = e.args[2]
      else
        path = joinpath([dir, e.args[2]])
      end
      @info "Including $(path)"
      code = join(readlines(path), "\n")
      #get directory of included file
      st = Meta.parseall(code, filename=path)
      static_solve_include(st, dirname(path))
    else
      e
    end
  end
end

function squash_toplevel_inside_block(ex)
  if ex isa Expr
    args = Meta.isexpr(ex, :block) ? [Meta.isexpr(a, :toplevel) ? a.args : [a] for a in ex.args] |> flat : ex.args
    newargs = squash_toplevel_inside_block.(args)
    Expr(ex.head, newargs...)
  else
    ex
  end
end

@inline function expand_specific_macros(macros_to_expand, expr)
  postwalk(expr) do e
    if Meta.isexpr(e, :macrocall) && e.args[1] in macros_to_expand
      Meta.macroexpand(@__MODULE__, e)
    else
      e
    end
  end
end

function pre_weave(dir, preserve_linenumbernodes)
  (v::Any) -> begin
    p1 = static_solve_include(v, dir)
    p11 = squash_toplevel_inside_block(p1)
    p2 = expand_specific_macros(aj_macros_to_expand, p11)
    p3 = (preserve_linenumbernodes ? identity : Base.remove_linenums!)(p2)
    p3
  end
end

# remove aj related node generated during weaving in syntax tree
function post_weave()
  Y(f -> (v::Any) -> (v isa Expr) ? Expr(v.head, [f(a) for a in v.args if !(a isa AJNodeType)]...) : v)
end

# remove aj related node to convert it to pure syntax tree 
function sanitize()
  Y(f -> (v::Any) ->
    if Meta.isexpr(v, :macrocall) && v.args[1] in aj_macros_to_expand
      f(v.args[4])
    elseif v isa Expr
      Expr(v.head, f.(v.args)...)
    else
      v
    end)
end