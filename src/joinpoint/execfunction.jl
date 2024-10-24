
@defparam struct JoinPointExecutionFunction <: JoinPoint
  pointcut::Pointcut
  original_full_expr::Expr # expr containing the function definition
  name::Symbol
  original_arg_exprs::Array
  original_body_expr::Expr # body expr
end

@export_valwithalias JoinPointExecutionFunction


function need_preresolveargs(::JoinPointParamExecutionFunction)
  false
end

function preresolve(param::JoinPointParamExecutionFunction, st::Expr, ::Bool, sym_prefix::Symbol)

  function arginfo_from_execfunc(argexprs)
    function split_symbol_type(e)
      if e isa Symbol
        (argtype=:normal, symbol=e,)
      elseif ex_isexpr(e, :(::))
        args = e |> ex_args
        (argtype=:normal, symbol=args[1], type=args[2])
      elseif ex_isexpr(e, :(...))
        args = e |> ex_args
        merge(split_symbol_type(args[1]), (isvariadic=true,))
      elseif ex_isexpr(e, :kw)
        args = e |> ex_args
        merge(split_symbol_type(args[1]), (default=args[2],))
      else
        @error "Invalid argument expression: $e"
      end
    end

    map(argexprs) do x
      if ex_isexpr(x, :parameters)
        map(x |> ex_args) do y
          merge(split_symbol_type(y), (argtype=:kw,))
        end
      else
        [split_symbol_type(x)]
      end
    end |> flat
  end

  exhead = st |> ex_head
  exargs = st |> ex_args

  arginfo = arginfo_from_execfunc(param.original_arg_exprs)
  arg_normal = filter(a -> a.argtype == :normal, arginfo)
  arg_kw = filter(a -> a.argtype == :kw, arginfo)
  tmp_n = [x.symbol for x in arg_normal]
  tmp_k = [x.symbol for x in arg_kw]

  st_pre_call = []
  st_base = Expr(exhead, exargs...)
  st_info = [Expr(:tuple,
    Expr(:(=), :args, Expr(:vect, tmp_n...)),
    Expr(:(=), :kargs, Expr(:call, :Dict, Expr(:vect, [Expr(:tuple, Expr(:quote, s), s) for s in tmp_k]...))))]

  ([], st_pre_call, st_base, st_info)

end