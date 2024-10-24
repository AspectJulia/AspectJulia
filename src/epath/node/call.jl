
struct FunctionCallNode <: ExprType
  siblings::Array
  children::Array
  full_expr::Expr
  name::Union{Symbol,Expr,Nothing}
  referers::Array{Referer}
  arg_exprs::Array
  isparallel::Bool
  attributes::Array
  function FunctionCallNode(siblings, children, full_expr, name, referers, arg_exprs, isparallel, attributes)
    new(
      filter_siblings(siblings),
      filter_children(children),
      to_nativeexpr(full_expr),
      to_nativeexpr(name),
      to_nativereferers(referers),
      to_nativeexpr.(arg_exprs),
      isparallel,
      attributes)
  end
end

function to_path(node::FunctionCallNode)
  ans = "call"
  if node.isparallel
    ans *= "[@parallel]"
  end
  if !isnothing(node.name)
    ans *= "[@name=\'$(node.name)\']"
  end
  if !is_empty_referer(node.referers)
    ans *= "[@ref=\'$(referers_to_str(node.referers))\']"
  end
  ans *= "[@argc=\'$(length(node.arg_exprs))\']"
  for attr in node.attributes
    ans *= "[@attr=\'$(attr)\']"
  end
  ans
end

function to_xml(node::FunctionCallNode)
  n = EzXML.ElementNode("call")
  if node.isparallel
    EzXML.link!(n, EzXML.AttributeNode("parallel", "true"))
  end
  if !isnothing(node.name)
    EzXML.link!(n, EzXML.AttributeNode("name", string(node.name)))
  end
  if !is_empty_referer(node.referers)
    EzXML.link!(n, EzXML.AttributeNode("ref", referers_to_str(node.referers)))
  end
  EzXML.link!(n, EzXML.AttributeNode("argc", node.arg_exprs |> length |> string))
  n
end

function to_jpparm(node::FunctionCallNode)
  JoinPointParamCallFunction(node.full_expr, node.name, node.referers, node.arg_exprs)
end