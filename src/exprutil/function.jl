
function is_functiondef(e::Expr)
  Meta.isexpr(e, :function) ||
    (Meta.isexpr(v, :(=)) && Meta.isexpr(v.args[1], :call)) ||
    (Meta.isexpr(v, :(=)) && Meta.isexpr(v.args[2], :(->))) ||
    (Meta.isexpr(v, :(->)))
end

mutable struct FunctionDef
  name::Nullable{Symbol}
  args::Array{Expr}
  body::Expr
end

function deconstruct_function(e::Expr)
  Base.remove_linenums!(e)
  if is_functiondef(e)
    if Meta.isexpr(e, :function)
      name = e.args[1].args[1]
      args = e.args[1].args[2:end]
      body = e.args[2]
    elseif Meta.isexpr(e, :(=)) && Meta.isexpr(e.args[1], :call)
      name = e.args[1]
      args = e.args[1].args[2:end]
      body = e.args[2]
    elseif Meta.isexpr(e, :(=)) && Meta.isexpr(e.args[2], :(->))
      name = e.args[1]
      args = []
      body = e.args[2]
    elseif Meta.isexpr(e, :(->))
      name = nothing
      args = e.args[1:end-1]
      body = e.args[end]
    end
    FunctionDef(name, args, body)
  else
    nothing
  end

end
