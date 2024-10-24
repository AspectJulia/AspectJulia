struct GeneratorNode <: ForNode
  siblings::Array
  children::Array
  full_expr::Expr
  ranges::Array
  body_expr
  attributes::Array
  function GeneratorNode(siblings, children, full_expr, ranges, body_expr, attributes)
    new(
      filter_siblings(siblings),
      filter_children(children),
      to_nativeexpr(full_expr),
      to_nativeexpr.(ranges),
      to_nativeexpr(body_expr),
      attributes)
  end
end

function to_path(node::GeneratorNode)
  ans = "for[@iterc=\'$(length(node.ranges))\'][@comprehension]"
  for attr in node.attributes
    ans *= "[@attr=\'$(attr)\']"
  end
  ans
end

function to_xml(node::GeneratorNode)
  n = EzXML.ElementNode("for")
  EzXML.link!(n, EzXML.AttributeNode("iterc", node.ranges |> length |> string))
  EzXML.link!(n, EzXML.AttributeNode("comprehension", "true"))
  n
end

function to_jpparm(node::GeneratorNode)
  JoinPointParamDefault(node.full_expr)
end