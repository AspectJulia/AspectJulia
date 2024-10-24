struct ReferenceNode <: ExprType
  siblings::Array
  children::Array
  full_expr::Expr
  name::Symbol
  referers::Array{Referer}
  attributes::Array
  function ReferenceNode(siblings, children, full_expr, name, referers, attributes)
    new(
      filter_siblings(siblings),
      filter_children(children),
      to_nativeexpr(full_expr),
      name,
      to_nativereferers(referers),
      attributes)
  end
end

function to_path(node::ReferenceNode)
  ans = "ref[@name=\'$(node.name)\']"
  if !is_empty_referer(node.referers)
    ans *= "[@ref=\'$(referers_to_str(node.referers))\']"
  end
  for attr in node.attributes
    ans *= "[@attr=\'$(attr)\']"
  end
  ans
end

function to_xml(node::ReferenceNode)
  n = EzXML.ElementNode("ref")
  EzXML.link!(n, EzXML.AttributeNode("name", string(node.name)))
  if !is_empty_referer(node.referers)
    EzXML.link!(n, EzXML.AttributeNode("ref", referers_to_str(node.referers)))
  end
  n
end

function to_jpparm(node::ReferenceNode)
  JoinPointParamReference(node.full_expr, node.name, node.referers)
end