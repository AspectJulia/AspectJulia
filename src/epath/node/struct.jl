struct StructNode <: ObjectExprType
  siblings::Array
  children::Array
  full_expr::Expr
  name::Symbol
  ismutable::Bool
  body_expr::Expr
  attributes::Array
  function StructNode(siblings, children, full_expr, name, ismutable, body_expr, attributes)
    new(
      filter_siblings(siblings),
      filter_children(children),
      to_nativeexpr(full_expr),
      name,
      ismutable,
      to_nativeexpr(body_expr),
      attributes)
  end
end

function to_path(node::StructNode)
  ans = "struct[@name=\'$(node.name)\']"
  if node.ismutable
    ans *= "[@mutable]"
  end
  for attr in node.attributes
    ans *= "[@attr=\'$(attr)\']"
  end
  ans
end

function to_xml(node::StructNode)
  n = EzXML.ElementNode("struct")
  EzXML.link!(n, EzXML.AttributeNode("name", string(node.name)))
  if node.ismutable
    EzXML.link!(n, EzXML.AttributeNode("mutable", "true"))
  end
  n
end

function to_jpparm(node::StructNode)
  JoinPointParamObject(node.full_expr, node.name, :struct, node.ismutable, node.body_expr)
end
