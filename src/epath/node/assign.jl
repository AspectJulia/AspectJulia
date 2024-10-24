struct AssignmentNode <: ExprType
  siblings::Array
  children::Array
  full_expr::Expr
  name::Symbol
  referers::Array{Referer}
  value_expr
  attributes::Array
  function AssignmentNode(siblings, children, full_expr, name, referers, value_expr, attributes)
    new(
      filter_siblings(siblings),
      filter_children(children),
      to_nativeexpr(full_expr),
      name,
      to_nativereferers(referers),
      to_nativeexpr(value_expr),
      attributes)
  end
end

function to_path(node::AssignmentNode)
  ans = "assign[@name=\'$(node.name)\']"
  if !is_empty_referer(node.referers)
    ans *= "[@ref=\'$(referers_to_str(node.referers))\']"
  end
  for attr in node.attributes
    ans *= "[@attr=\'$(attr)\']"
  end
  ans
end

function to_xml(node::AssignmentNode)
  n = EzXML.ElementNode("assign")
  EzXML.link!(n, EzXML.AttributeNode("name", string(node.name)))
  if !is_empty_referer(node.referers)
    EzXML.link!(n, EzXML.AttributeNode("ref", referers_to_str(node.referers)))
  end
  n
end

function to_jpparm(node::AssignmentNode)
  JoinPointParamAssignment(node.full_expr, node.name, node.referers, node.value_expr)
end