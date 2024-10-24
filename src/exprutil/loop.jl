
function is_loop(e::Expr)
  Meta.isexpr(e, :for)
end

mutable struct LoopDef
  ranges::Array{Expr}
  body::Expr
end

function deconstruct_loop(e::Expr)
  Base.remove_linenums!(e)
  if Meta.isexpr(e, :for)
    ranges = Meta.isexpr(e.args[1], :block) ? e.args[1].args : [e.args[1]]
    body = e.args[2]
    LoopDef(ranges, body)
  else
    nothing
  end
end

function reconstruct_loop(def::LoopDef)
  Expr(:for, length(def.ranges) == 1 ? def.ranges[1] : Expr(:block, def.ranges...), def.body)
end

function u_reverserange!(def::LoopDef)
  def.ranges = reverse(def.ranges)
end

function u_reverserange(e::Expr)
  def = deconstruct_loop(e)
  if isnothing(def)
    @error "Not a loop"
  end
  u_reverserange!(def)
  reconstruct_loop(def)
end