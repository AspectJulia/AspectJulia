function generate_structure_xml(st)
  xmlnodes = Y(f -> (ex, parent_ex, argindex) -> begin

    function donext(t::Nullable{ExprType})
      if isnothing(t)
        []
      else
        siblings = map(cn -> f(cn, parent_ex, argindex), t.siblings) |> flat
        children = map(cn_wi -> f(cn_wi[2], ex, cn_wi[1]), t.children) |> flat
        if t isa IgnoreNode
          [siblings..., children...]
        else
          node = to_xml(t)
          for c in children
            EzXML.link!(node, c)
          end
          [node, siblings...]
        end
      end
    end

    try
      v = extract(ex, parent_ex, argindex)
      if v isa Array
        map(donext, v) |> flat
      else
        donext(v)
      end
    catch e
      @info "Error: $ex"
      @info e
      []
    end
  end)(st, nothing, 1)

  root = EzXML.ElementNode("joinpoint")

  for n in xmlnodes
    EzXML.link!(root, n)
  end

  doc = EzXML.XMLDocument()
  EzXML.setroot!(doc, root)
end

function xml_node_to_fullepath(node)
  if node.name == "joinpoint" #  it is root node
    ""
  elseif !EzXML.hasparentnode(node)
    @error "No parent node"
  else
    attrstr = map(EzXML.attributes(node)) do a
      "[@$(a.name)=\'$(a.content)\']"
    end |> join
    xml_node_to_fullepath(EzXML.parentnode(node)) * "/$(node.name)$(attrstr)"
  end
end

function findpath(st::Expr, xpath::String)
  sxml = generate_structure_xml(st)
  nodes = EzXML.findall(xpath, sxml)
  xml_node_to_fullepath.(nodes)
end