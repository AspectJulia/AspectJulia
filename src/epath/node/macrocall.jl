struct MacroCallNode <: ExprType
  siblings::Array
  children::Array
  full_expr::Expr
  name::Symbol
  args::Array
  attributes::Array
  function MacroCallNode(siblings, children, full_expr, name, args, attributes)
    new(
      filter_siblings(siblings),
      filter_children(children),
      to_nativeexpr(full_expr),
      name,
      args,
      attributes)
  end
end

function to_path(node::MacroCallNode)
  ans = "macrocall[@name=\'$(node.name)\']"
  for attr in node.attributes
    ans *= "[@attr=\'$(attr)\']"
  end
  ans
end

function to_xml(node::MacroCallNode)
  n = EzXML.ElementNode("macrocall")
  EzXML.link!(n, EzXML.AttributeNode("name", string(node.name)))
  n
end

function to_jpparm(node::MacroCallNode)
  JoinPointParamDefault(node.full_expr) #FIXME
end