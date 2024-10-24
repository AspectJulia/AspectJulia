
# AjNode Structure
## head : :aj
## args[1] : AdviceInfoSet
## args[2] : Expr head
## args[3:end] : Expr args

@inline ex_head(v)::Union{Symbol,Nothing} = v isa Expr ? (Meta.isexpr(v, :aj) ? v.args[2] : v.head) : nothing

@inline ex_isexpr(ex, head::Symbol)::Bool = Meta.isexpr(ex, head) || (Meta.isexpr(ex, :aj) && ex.args[2] == head)

@inline ex_args(v)::Array = v isa Expr ? (Meta.isexpr(v, :aj) ? v.args[3:end] : v.args) : []

@inline ex_parse(v) = v isa Expr ? ((Meta.isexpr(v, :aj) ? v.args[2] : v.head), (Meta.isexpr(v, :aj) ? v.args[3:end] : v.args)) : (nothing, [])

@inline ex_argsn(n) = (v) -> ex_args(v) |> getn(n)

@inline to_nativeexpr(v) = postwalk(x -> Meta.isexpr(x, :aj) ? Expr(x.args[2:end]...) : x, v)
