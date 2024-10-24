
@defparam struct JoinPointReference <: JoinPoint
  pointcut::Pointcut
  original_full_expr::Expr
  name::Symbol
  referers
end

@export_valwithalias JoinPointReference

JoinPointReferenceArray = JoinPointReference
@export_valwithalias JoinPointReferenceArray

JoinPointReferenceStruct = JoinPointReference
@export_valwithalias JoinPointReferenceStruct


function need_preresolveargs(::JoinPointParamReference)
  true
end

function preresolve(param::JoinPointParamReference, x::Expr, do_preresolveargs::Bool, sym_prefix::Symbol)
  exhead = x |> ex_head
  exargs = x |> ex_args

  if do_preresolveargs
    if length(param.referers) == 0
      @info "No referers is found for $(param.target)"
    else
      (tmp_st_pre_call, tmp_st_base, tmp_st_info) = gen_precall4ref(param.referers, param.name, sym_prefix)
      st_pre_call = tmp_st_pre_call
      st_base = tmp_st_base
      st_info = [tmp_st_info]
    end
  else
    st_pre_call = []
    st_base = Expr(exhead, exargs...)
    st_info = []
  end

  ([], st_pre_call, st_base, st_info)

end