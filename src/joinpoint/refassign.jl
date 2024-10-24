@defparam struct JoinPointReferenceAssignment <: JoinPoint
  pointcut::Pointcut
  original_full_expr::Expr
  name::Symbol
  referers
  original_value_expr::Any
  op::Symbol
end

@export_valwithalias JoinPointReferenceAssignment

function need_preresolveargs(::JoinPointParamReferenceAssignment)
  true
end


function preresolve(param::JoinPointParamReferenceAssignment, x::Expr, do_preresolveargs::Bool, sym_prefix::Symbol)
  exhead = x |> ex_head
  exargs = x |> ex_args

  if do_preresolveargs
    if length(param.referers) == 0
      @info "No referers is found for $(param.target)"
    else
      (tmp_st_pre_call, tmp_st_base, tmp_st_info) = gen_precall4ref(param.referers, param.name, sym_prefix)
      sym = Symbol(sym_prefix, "#", :val)
      st_pre_call = [tmp_st_pre_call..., Expr(:(=), sym, exargs[2])]
      st_base = Expr(exhead, tmp_st_base, sym)
      st_info = [tmp_st_info, sym, param.op]
    end
  else
    st_pre_call = []
    st_base = Expr(exhead, exargs...)
    st_info = []
  end

  ([], st_pre_call, st_base, st_info)

end