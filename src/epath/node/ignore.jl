struct IgnoreNode <: ExprType
  siblings::Array
  children::Array
  function IgnoreNode(siblings, children=[])
    new(
      filter_siblings(siblings),
      filter_children(children))
  end

end

function to_xml(::IgnoreNode)
  EzXML.ElementNode("**ERROR**")
end