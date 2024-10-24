abstract type Referer end

struct IndexReferer <: Referer
  refexpr
end

struct FieldReferer <: Referer
  refname
end

struct TupleReferer <: Referer
  nth::Int64
end

struct Unresolved <: Referer
  refexpr
end

function is_empty_referer(referers)
  length(filter(r -> !(r isa Unresolved), referers)) == 0
end

function may_declare_referer(referers)
  length(filter(r -> !(r isa Unresolved || r isa TupleReferer), referers)) == 0
end


function parse_ref(e)

  head = e |> ex_head
  args = e |> ex_args
  if head == :ref
    [(name, [refs..., IndexReferer(args[2])]) for (name, refs) in parse_ref(args[1])]
  elseif head == :(.) && args[2] isa QuoteNode
    [(name, [refs..., FieldReferer(args[2])]) for (name, refs) in parse_ref(args[1])]
  elseif head == :(::)
    parse_ref(args[1])
  elseif head == :tuple
    map(enumerate(args)) do (i, arg)
      [(name, [refs..., TupleReferer(i)]) for (name, refs) in parse_ref(arg)]
    end |> flat
  elseif head == :curly || e isa Symbol
    [(e, [])]
  elseif !isnothing(e)
    [(nothing, [Unresolved(e)])]
  else
    @info "Not supported node, $e"
  end

end


function referers_to_str(referers, init="%")
  if length(referers) == 0
    init
  else
    r = referers[1]
    if r isa IndexReferer
      referers_to_str(referers[2:end], "$init[]")
    elseif r isa FieldReferer
      referers_to_str(referers[2:end], "$init.$(r.refname.value)")
    elseif r isa TupleReferer
      referers_to_str(referers[2:end], "($(repeat(",", r.nth-1))$init$(r.nth == 1 ? "," : "" ))")
    elseif r isa Unresolved
      @info "Unresolved referer found"
    else
      referers_to_str(referers[2:end], init)
    end
  end
end

function get_siblings(referers)
  map(r -> r.refexpr, filter(r -> r isa IndexReferer || r isa Unresolved, referers))
end

function gen_precall4ref(referers, name, sym_prefix::Symbol)

  st_base = name
  st_pre_call = []
  st_info = []

  for (index, ref) in enumerate(referers)
    tag = Symbol(sym_prefix, "#", :ref, index)
    if ref isa IndexReferer
      push!(st_pre_call, Expr(:(=), tag, ref.refexpr))
      push!(st_info, Expr(:tuple, Expr(:(=), :type, QuoteNode(:index)), Expr(:(=), :value, tag)))
      st_base = Expr(:ref, st_base, tag)
    elseif ref isa FieldReferer
      push!(st_info, Expr(:tuple, Expr(:(=), :type, QuoteNode(:field)), Expr(:(=), :value, ref.refname)))
      st_base = Expr(:., st_base, ref.refname)
    elseif ref isa TupleReferer
      push!(st_info, Expr(:tuple, Expr(:(=), :type, QuoteNode(:tuple)), Expr(:(=), :value, ref.nth)))
      st_base = Expr(:tuple, (i == ref.nth ? st_base : :_ for i in 1:ref.nth)...)
    else
      @info "Not supported referer, $ref"
    end
  end

  (st_pre_call, st_base, Expr(:vect, st_info...))

end

function to_nativereferers(referers)
  map(referer -> if referer isa IndexReferer
      IndexReferer(to_nativeexpr(referer.refexpr))
    elseif referer isa Unresolved
      Unresolved(to_nativeexpr(referer.refexpr))
    else
      referer
    end, referers)
end