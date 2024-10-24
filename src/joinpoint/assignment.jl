
@defparam struct JoinPointAssignment <: JoinPoint
  pointcut::Pointcut
  original_full_expr::Expr
  name::Symbol
  referers
  original_value_expr::Any
end

@export_valwithalias JoinPointAssignment

JoinPointAssignmentArray = JoinPointAssignment
@export_valwithalias JoinPointAssignmentArray

JoinPointAssignmentStruct = JoinPointAssignment
@export_valwithalias JoinPointAssignmentStruct



function need_preresolveargs(::JoinPointParamAssignment)
  true
end

function preresolve(param::JoinPointParamAssignment, st::Expr, do_preresolveargs::Bool, sym_prefix::Symbol)
  exhead = st |> ex_head
  exargs = st |> ex_args

  if do_preresolveargs
    if may_declare_referer(param.referers)
      st_init = [
        Expr(:if, Expr(:call, :!, Expr(:macrocall, Symbol("@isdefined"), LineNumberNode(0, ""), param.name)), Expr(:(=), param.name, :nothing))
      ]
    else
      st_init = []
    end

    (tmp_st_pre_call, tmp_st_base, tmp_st_info) = gen_precall4ref(param.referers, param.name, sym_prefix)
    sym = Symbol(sym_prefix, "#", :val)
    st_pre_call = [tmp_st_pre_call..., Expr(:(=), sym, exargs[2])]
    st_base = Expr(exhead, tmp_st_base, sym)
    st_info = [tmp_st_info, sym]
  else
    st_init = []
    st_pre_call = []
    st_base = Expr(exhead, exargs...)
    st_info = []
  end

  (st_init, st_pre_call, st_base, st_info)

end
