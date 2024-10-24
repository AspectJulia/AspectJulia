struct MacroDefintionNode <: ExprType
  siblings::Array
  children::Array
  full_expr::Expr
  name::Symbol
  body_expr::Expr
  attributes::Array
  function MacroDefintionNode(siblings, children, full_expr, name, body_expr, attributes)
    new(
      filter_siblings(siblings),
      filter_children(children),
      to_nativeexpr(full_expr),
      name,
      to_nativeexpr(body_expr),
      attributes)
  end
end

function to_path(node::MacroDefintionNode)
  ans = "macro[@name=\'$(node.name)\']"
  for attr in node.attributes
    ans *= "[@attr=\'$(attr)\']"
  end
  ans
end

function to_xml(node::MacroDefintionNode)
  n = EzXML.ElementNode("macro")
  EzXML.link!(n, EzXML.AttributeNode("name", string(node.name)))
  n
end

function to_jpp(node::MacroDefintionNode)
  JoinPointParamDefault(node.full_expr)
end