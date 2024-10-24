abstract type ExprType end

@inline function filter_siblings(siblings)
  filter(x -> !(x isa AJNodeType), siblings)
end

@inline function filter_children(children)
  filter(x -> !(x[2] isa AJNodeType), children)
end
