struct ReferenceAssignmentNode <: ExprType
  siblings::Array
  children::Array
  full_expr::Expr
  name::Symbol
  referers::Array{Referer}
  value_expr
  op::Symbol
  attributes::Array
  function ReferenceAssignmentNode(siblings, children, full_expr, name, referers, value_expr, op, attributes)
    new(
      filter_siblings(siblings),
      filter_children(children),
      to_nativeexpr(full_expr),
      name,
      to_nativereferers(referers),
      to_nativeexpr(value_expr),
      op,
      attributes)
  end
end

function to_path(node::ReferenceAssignmentNode)
  ans = "assign[@op=\'$(node.op)\'][@name=\'$(node.name)\']"
  if !is_empty_referer(node.referers)
    ans *= "[@ref=\'$(referers_to_str(node.referers))\']"
  end
  for attr in node.attributes
    ans *= "[@attr=\'$(attr)\']"
  end
  ans
end

function to_xml(node::ReferenceAssignmentNode)
  n = EzXML.ElementNode("assign")
  EzXML.link!(n, EzXML.AttributeNode("op", string(node.op)))
  EzXML.link!(n, EzXML.AttributeNode("name", string(node.name)))
  if !is_empty_referer(node.referers)
    EzXML.link!(n, EzXML.AttributeNode("ref", referers_to_str(node.referers)))
  end
  n
end

function to_jpparm(node::ReferenceAssignmentNode)
  JoinPointParamReferenceAssignment(node.full_expr, node.name, node.referers, node.value_expr, node.op)
end