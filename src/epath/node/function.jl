function funcdefargs_to_str(args)
  norm_args = filter(a -> !ex_isexpr(a, :parameters), args)
  kw_args = filter(a -> ex_isexpr(a, :parameters), args)

  args_str = map(a -> ex_isexpr(a, :kw) ? "$(ex_args(a)[1])=" : string(a), norm_args) |> Base.Fix2(join, ",")

  if length(kw_args) > 1
    @error "Mulformed function arguments, $args"
  elseif length(kw_args) == 1
    args_str *= ";"
    args_str *= map(a -> ex_isexpr(a, :kw) ? "$(ex_args(a)[1])=" : "$a", kw_args[1].args) |> Base.Fix2(join, ",")
  end

  args_str
end

struct FunctionDefintionNode <: ExprType
  siblings::Array
  children::Array
  full_expr::Expr
  name::Nullable{Symbol}
  arg_exprs::Array
  body_expr::Expr
  attributes::Array
  function FunctionDefintionNode(siblings, children, full_expr, name, arg_exprs, body_expr, attributes)
    new(
      filter_siblings(siblings),
      filter_children(children),
      to_nativeexpr(full_expr),
      name,
      to_nativeexpr.(arg_exprs),
      to_nativeexpr(body_expr),
      attributes)
  end
end

function to_path(node::FunctionDefintionNode)
  ans = "function"
  if !isnothing(node.name)
    ans *= "[@name=\'$(node.name)\']"
  end
  if length(node.arg_exprs) > 0
    ans *= "[@args=\'$(funcdefargs_to_str(node.arg_exprs))\']"
  end
  for attr in node.attributes
    ans *= "[@attr=\'$(attr)\']"
  end
  ans
end

function to_xml(node::FunctionDefintionNode)
  n = EzXML.ElementNode("function")
  if !isnothing(node.name)
    EzXML.link!(n, EzXML.AttributeNode("name", string(node.name)))
  end
  if length(node.arg_exprs) > 0
    EzXML.link!(n, EzXML.AttributeNode("args", funcdefargs_to_str(node.arg_exprs)))
  end
  n
end

function to_jpparm(node::FunctionDefintionNode)
  JoinPointParamExecutionFunction(node.full_expr, node.name, node.arg_exprs, node.body_expr)
end
