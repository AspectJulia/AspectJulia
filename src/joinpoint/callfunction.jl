
@defparam struct JoinPointCallFunction <: JoinPoint
  pointcut::Pointcut
  original_full_expr::Expr
  name::Symbol
  referers
  original_arg_exprs::Array
end

@export_valwithalias JoinPointCallFunction


function need_preresolveargs(::JoinPointParamCallFunction)
  true
end

function arginfo_from_callfunc(argexprs)
  function remove_type(e)
    ex_isexpr(e, :(::)) ? e |> ex_args |> getn(1) : e
  end

  function checkvariadic(e)
    if ex_isexpr(e, :(...))
      (isvariadic=true, e=remove_type(e |> ex_args |> getn(1)))
    else
      (isvariadic=false, e=remove_type(e))
    end
  end

  function split_symbol_type(e)
    if ex_isexpr(e, :kw)
      args = e |> ex_args
      merge((argtype=:kw, symbol=args[1],), checkvariadic(args[2]))
    else
      merge((argtype=:normal,), checkvariadic(e))
    end
  end

  map(argexprs) do x
    if ex_isexpr(x, :parameters)
      map(x |> ex_args) do y
        split_symbol_type(y)
      end
    else
      [split_symbol_type(x)]
    end
  end |> flat
end

function preresolve(param::JoinPointParamCallFunction, st::Expr, do_preresolveargs::Bool, sym_prefix::Symbol)

  exhead = st |> ex_head
  exargs = st |> ex_args

  arginfo = arginfo_from_callfunc(param.original_arg_exprs)
  arg_normal = filter(a -> a.argtype == :normal, arginfo)
  arg_kw = filter(a -> a.argtype == :kw, arginfo)

  if do_preresolveargs
    (tmp_st_pre_call, tmp_st_base, tmp_st_info) = gen_precall4ref(param.referers, param.name, sym_prefix)

    tmp_n = [
      begin
        sym = Symbol(sym_prefix, "#", :arg, i)
        (x.isvariadic ? Expr(:(...), sym) : sym, Expr(:(=), sym, x.e))
      end for (i, x) in enumerate(arg_normal)
    ]
    tmp_k = [
      begin
        sym = Symbol(sym_prefix, "#", :kwarg, i)
        (x.symbol, sym, Expr(:(=), sym, x.e))
      end for (i, x) in enumerate(arg_kw)
    ]
    st_pre_call = [tmp_st_pre_call..., map(getn(2), tmp_n)..., map(getn(3), tmp_k)...]
    st_base = Expr(exhead, tmp_st_base, map(getn(1), tmp_n)..., map(k -> Expr(:kw, k[1], k[2]), tmp_k)...)
    st_info = [
      tmp_st_info,
      Expr(:tuple,
        Expr(:(=), :args, Expr(:vect, map(getn(1), tmp_n)...)),
        Expr(:(=), :kargs, Expr(:call, :Dict, Expr(:vect, [Expr(:tuple, Expr(:quote, s[1]), s[2]) for s in tmp_k]...))))]
  else
    st_pre_call = []
    st_base = Expr(exhead, exargs...)
    st_info = []
  end

  ([], st_pre_call, st_base, st_info)

end