"""Y combinator"""
Y = f -> (x -> x(x))(y -> f((t...) -> y(y)(t...)))


"""Nullable{T} = Union{T,Nothing}"""
Nullable{T} = Union{T,Nothing}


"""Get nth element of Array"""
@inline function getn(n::Int64, ary::AbstractArray)
  get(ary, n, nothing)
end

"""Get nth element of Tuple"""
@inline function getn(n::Int64, ary::Tuple)
  get(ary, n, nothing)
end

"""Generate function to get nth element"""
@inline getn(n::Int64) = Base.Fix1(getn, n)


"""Flatten Iterable items (ex. Array of Array)"""
@inline flat(a) = isnothing(a) || length(a) == 0 ? [] : collect(Iterators.flatten(a))

"""convert Array to String without type information"""
@inline conv_ary2str(a) = isnothing(a) ? "" : "[$(join(map(string, a), ", "))]"

"""convert Dict to String without type information"""
@inline conv_dict2str(d) = isnothing(d) ? "" : "Dict($(join(["$(k) => $(v)" for (k, v) in d], ", ")))"


## Walk AST

"""Post-order walk of AST"""
function postwalk(_, x::Any)
  x
end

"""Post-order walk of AST"""
function postwalk(f, x::Expr)
  new_args = [postwalk(f, a) for a in x.args]
  f(Expr(x.head, new_args...))
end

"""Pre-order walk of AST"""
function prewalk(_, x::Any)
  x
end

"""Pre-order walk of AST"""
function prewalk(f, x::Expr)
  f(x)
  new_args = [prewalk(f, a) for a in x.args]
  Expr(x.head, new_args...)
end


"""Abbreviation conversion rules"""
function shortname(name::Symbol)
  dict = Dict(
    "Pointcut" => "PC",
    "JoinPoint" => "JP",
    "Advice" => "AD",
    "Execution" => "Exec",
    "Function" => "Func",
    "Attribute" => "Attr",
    "Assignment" => "Assign",
    "Reference" => "Ref",
    "Mutable" => "Mut",
    "AppendFront" => "AppendF",
    "AppendBack" => "AppendB",
    "WithArgs" => "A"
  )
  Symbol(reduce((n, (k, v)) -> replace(n, k => v), dict, init=String(name)))
end


"""More abbreviation conversion rules"""
function veryshortname(name::Symbol)
  dict = Dict(
    "Struct" => "St",
    "Array" => "Ary",
    "Running" => "R",
  )

  short = shortname(name)

  Symbol(reduce((n, (k, v)) -> replace(n, k => v), dict, init=String(short)))

end

"""Export macro and abbreviations, which are shortname and veryshortname"""
macro export_macrowithalias(ex::Expr)
  macroname = ex.args[1].args[1]

  alias1 = shortname(macroname)
  alias2 = veryshortname(macroname)

  names = unique([macroname, alias1, alias2])

  exprs = [Expr(:macro, Expr(:call, name, ex.args[1].args[2:end]...), ex.args[2:end]...) for name in names]

  exports = Expr(:export, [Symbol("@", name) for name in names]...)

  esc(Expr(
    :toplevel,
    exprs...,
    exports,
    Expr(:macrocall, Symbol("@debug"), __source__, Expr(:string, "export ", names))
  ))
end
