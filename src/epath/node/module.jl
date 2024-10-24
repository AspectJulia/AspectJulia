struct ModuleNode <: ObjectExprType
  siblings::Array
  children::Array
  full_expr::Expr
  name::Symbol
  isnotbare::Bool
  body_expr::Expr
  attributes::Array
  function ModuleNode(siblings, children, full_expr, name, isnotbare, body_expr, attributes)
    new(
      filter_siblings(siblings),
      filter_children(children),
      to_nativeexpr(full_expr),
      name,
      isnotbare,
      to_nativeexpr(body_expr),
      attributes)
  end
end

function to_path(node::ModuleNode)
  ans = "module[@name=\'$(node.name)\']"
  if !node.isnotbare
    ans *= "[@bare]"
  end
  for attr in node.attributes
    ans *= "[@attr=\'$(attr)\']"
  end
  ans
end

function to_xml(node::ModuleNode)
  n = EzXML.ElementNode("module")
  EzXML.link!(n, EzXML.AttributeNode("name", string(node.name)))
  if !node.isnotbare
    EzXML.link!(n, EzXML.AttributeNode("bare", "true"))
  end
  n
end

function to_jpparm(node::ModuleNode)
  JoinPointParamObject(node.full_expr, node.name, :module, node.isnotbare, node.body_expr)
end

