
@inline ex_getfunctionparams(v::Any)::(@NamedTuple{functionname::Union{Symbol,Nothing}, args::Array}) =
  if ex_isexpr(v, :call)
    if ex_args(v)[1] == :(|>)
      (functionname=v |> ex_args |> getn(3), args=[v |> ex_args |> x -> x[2]])
    else
      (functionname=v |> ex_args |> getn(1), args=v |> ex_args |> x -> x[2:end] |> ls -> filter(t -> !(t isa AttributeNode), ls))
    end
  else
    (functionname=nothing, args=ArgElem[])
  end

