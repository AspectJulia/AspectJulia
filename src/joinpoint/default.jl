
@defparam struct JoinPointDefault <: JoinPoint
  pointcut::Pointcut
  original_full_expr::Expr
end

@export_valwithalias JoinPointDefault

function need_preresolveargs(::JoinPointParamDefault)
  true
end

function preresolve(::JoinPointParamDefault, x::Expr, ::Bool, ::Symbol)
  exhead = x |> ex_head
  exargs = x |> ex_args

  st_base = Expr(exhead, exargs...)

  ([], [], st_base, [])

end








# function get_init_st(any)
#   []
# end

# function gen_init_st(param::JoinPointParamAssignment)
#   if may_declare_referer(param.referers)
#     [
#       Expr(:if, Expr(:call, :!, Expr(:macrocall, Symbol("@isdefined"), LineNumberNode(0, ""), param.name)), Expr(:(=), param.name, :nothing))
#     ]
#   else
#     []
#   end
# end

# function gen_precall4ref(referers, name)
#   st_pre_call = []
#   st_base = name
#   st_info = []
#   (st_pre_call, st_base, st_info)
# end
