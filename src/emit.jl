


function emit(st, sym_prefix::Symbol=gensym())

  st_result_symbol = Symbol(sym_prefix, "#", :result)
  st_resulttmp_symbol = Symbol(sym_prefix, "#", :resulttmp)
  st_exception_symbol = Symbol(sym_prefix, "#", :e)

  function call_generator(advice::Advice, pc::Pointcut, param::JoinPointParam, otherargs...)
    try
      generated = advice.generator(create_joinpoint(pc, param), otherargs...)
      if generated isa Expr
        generated
      else
        @error "generator must return Expr. Given: $(typeof(generated))"
      end
    catch e
      if e isa MethodError
        @error "cannot call generator. It may be due to to wrong type of arguments in the advice. Given arguments: $(typeof(otherargs)). Generator Function: $(typeof(advice.generator))."
      else
        throw(e)
      end
    end
  end

  function count_aj(ex)::Int
    if Meta.isexpr(ex, :aj)
      1 + sum(count_aj.(ex.args))
    elseif ex isa Expr
      sum(count_aj.(ex.args))
    else
      0
    end
  end

  if !(st isa Expr)
    st
  else

    @info "Number of JoinPoint: $(count_aj(st))"

    postwalk(st) do x
      if Meta.isexpr(x, :aj)

        aiset = x.args[1]

        if has_noadvice(aiset)

          st_comment = [convert(LineNumberNode, pc) for pc in aiset.debuginfo_pointcuts]
          Expr(:block, st_comment..., Expr(ex_head(x), ex_args(x)...))

        else

          # Check joinpoint Type (current Implementation only support one type of joinpoint)



          params = collect(Set([map(a -> a.param, aiset.before)...,
            map(a -> (a.param), aiset.around)...,
            map(a -> (a.param), aiset.after_running)...,
            map(a -> (a.param), aiset.after_throwing)...,
            map(a -> (a.param), aiset.after)...]))

          if length(params) > 1
            @info "multi type param for one joinpoint, is not yet implemented"
          end

          param = params[1]

          do_preresolveargs = need_preresolveargs(aiset)

          (st_init, st_pre_call, st_base, st_info) = preresolve(param, x, do_preresolveargs, sym_prefix)

          @inline function get_info(advice::Advice)
            if advice isa Advice_WithArgs
              st_info
            else
              []
            end
          end

          st_before = [[
            convert(LineNumberNode, ai.pointcut),
            Expr(:call, call_generator(ai.advice, ai.pointcut, param), get_info(ai.advice)...)
          ] for ai in aiset.before |> reverse] |> flat

          st_target = Expr(:block,
            [convert(LineNumberNode, ai.pointcut) for ai in aiset.around]...,
            foldl((ex, ai) -> begin
                if ai.advice isa Advice_Replace
                  call_generator(ai.advice, ai.pointcut, param, ex)
                elseif ai.advice isa Advice_AppendFront
                  Expr(:block, call_generator(ai.advice, ai.pointcut, param), ex)
                elseif ai.advice isa Advice_AppendBack
                  Expr(:block, ex, call_generator(ai.advice, ai.pointcut, param))
                else
                  @error "around advice must be either Advice_Replace or Advice_Append"
                end
              end, aiset.around, init=st_base)
          )

          st_afterrunning = [[
            convert(LineNumberNode, ai.pointcut),
            Expr(:call, call_generator(ai.advice, ai.pointcut, param), st_resulttmp_symbol, get_info(ai.advice)...)
          ] for ai in aiset.after_running] |> flat

          st_afterthrowing = [[
            convert(LineNumberNode, ai.pointcut),
            Expr(:call, call_generator(ai.advice, ai.pointcut, param), st_exception_symbol, get_info(ai.advice)...)
          ] for ai in aiset.after_throwing] |> flat

          st_after = [[
            convert(LineNumberNode, ai.pointcut),
            Expr(:call, call_generator(ai.advice, ai.pointcut, param), get_info(ai.advice)...)
          ] for ai in aiset.after] |> flat

          if need_tmpresult(aiset)
            st_main = Expr(:block,
              st_before...,
              Expr(:(=), st_resulttmp_symbol, st_target),
              st_afterrunning...,
              st_resulttmp_symbol)
          else
            st_main = Expr(:block,
              st_before...,
              st_target)
          end

          st_main_with_errorhandling = Expr(:try,
            st_main,
            st_exception_symbol,
            Expr(:block, st_afterthrowing..., Expr(:call, :throw, st_exception_symbol)),
            Expr(:block, st_after...)
          )

          if isempty(st_pre_call)
            st_ans = has_errorhandling(aiset) ? st_main_with_errorhandling : st_main
          else
            st_ans = Expr(:let, Expr(:block,
                st_pre_call...,
                Expr(:(=), st_result_symbol, has_errorhandling(aiset) ? st_main_with_errorhandling : st_main)
              ), Expr(:block, st_result_symbol))
          end

          if !isempty(st_init)
            st_ans = Expr(:block, st_init..., st_ans)
          end

          st_ans

        end


      else
        x
      end
    end

  end
end