export unpack

abstract type JoinPoint end

abstract type JoinPointParam end

function unpack(jp::JoinPoint)
  names = propertynames(jp)
  NamedTuple{names}([getproperty(jp, field) for field in names])
end

Base.show(io::IO, ::JoinPoint) = print(io, "JoinPoint")

macro defparam(ex)

  filtered = []
  new_field_names = []

  addflag = false
  for m in ex.args[3].args |> reverse
    if m isa LineNumberNode && addflag
      push!(filtered, m)
      addflag = false
    elseif m isa Symbol && m != :pointcut
      push!(filtered, m)
      push!(new_field_names, m)
      addflag = true
    elseif m isa Expr && m.args[1] != :pointcut
      push!(filtered, m)
      push!(new_field_names, m.args[1])
      addflag = true
    end
  end

  reverse!(filtered)
  reverse!(new_field_names)

  struct_name = ex.args[2].args[1]

  new_struct_name = Symbol(replace(string(struct_name), "JoinPoint" => "JoinPointParam"))

  ex_mod = Expr(:struct, false, Expr(:(<:), new_struct_name, :JoinPointParam), Expr(:block, filtered...))

  func = Expr(:function, Expr(:call, :create_joinpoint,
      Expr(:(::), :pc, :Pointcut), Expr(:(::), :param, new_struct_name)),
    Expr(:call, struct_name, :pc, [Expr(:(.), :param, QuoteNode(name)) for name in new_field_names]...))

  esc(Expr(:block, ex, ex_mod, func))

end

macro export_valwithalias(ex::Symbol)

  alias1 = shortname(ex)
  alias2 = veryshortname(ex)

  names = unique([ex, alias1, alias2])

  esc(Expr(
    :block,
    Expr(:export, names...),
    [Expr(:(=), name, ex) for name in names if name != ex]...,
    Expr(:macrocall, Symbol("@debug"), __source__, Expr(:string, "export ", names))))

end

include("default.jl")

include("assignment.jl")
include("execfunction.jl")
include("callfunction.jl")
include("object.jl")
include("refassign.jl")
include("reference.jl")

