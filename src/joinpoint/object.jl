
@defparam struct JoinPointObject <: JoinPoint
  pointcut::Pointcut
  original_full_expr::Expr
  name::Symbol
  jptype::Symbol
  flag::Bool
  original_body_expr::Expr
end

@export_valwithalias JoinPointObject

JoinPointModule = JoinPointObject
@export_valwithalias JoinPointModule

JoinPointStruct = JoinPointObject
@export_valwithalias JoinPointStruct


function need_preresolveargs(::JoinPointParamObject)
  false
end

function preresolve(::JoinPointParamObject, x::Expr, ::Bool, ::Symbol)
  exhead = x |> ex_head
  exargs = x |> ex_args

  st_base = Expr(exhead, exargs...)

  ([], [], st_base, [])

end