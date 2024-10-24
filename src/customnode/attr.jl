export @attr

struct AttributeNode <: AJNodeType
  name::Symbol
end

function appendmeta(name::Symbol, v::Expr)
  Expr(v.head, filter(!Base.Fix2(isa, AttributeNode), v.args)..., AttributeNode(name))
end

macro attr(tag, ex::Expr)
  esc(appendmeta(Symbol(tag), ex))
end

function ex_meta(st)
  map(t -> t.name, filter(x -> x isa AttributeNode, st |> ex_args))
end
