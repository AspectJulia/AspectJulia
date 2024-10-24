export &

abstract type Advice end

abstract type Advice_Insert <: Advice end

abstract type Advice_Replace <: Advice end

struct Advice_NoArg <: Advice_Insert
  generator::Function
end

struct Advice_WithArgs <: Advice_Insert
  generator::Function
end

struct Advice_All <: Advice_Replace
  generator::Function
end

struct Advice_AppendFront <: Advice_Replace
  generator::Function
end

struct Advice_AppendBack <: Advice_Replace
  generator::Function
end

struct Advices
  before::Nullable{Advice_Insert}
  around::Nullable{Advice_Replace}
  after_running::Nullable{Advice_Insert}
  after_throwing::Nullable{Advice_Insert}
  after::Nullable{Advice_Insert}

  function Advices(;
    before=nothing,
    around=nothing,
    after_running=nothing,
    after_throwing=nothing,
    after=nothing,
  )
    new(
      before,
      around,
      after_running,
      after_throwing,
      after,
    )
  end

  function Advices(vals::Dict)
    new(
      get(vals, :before, nothing),
      get(vals, :around, nothing),
      get(vals, :after_running, nothing),
      get(vals, :after_throwing, nothing),
      get(vals, :after, nothing),
    )
  end
end

import Base.&

function (&)(a::Advices, b::Advices)

  vals = Dict{Symbol,Advice}()

  for field in fieldnames(Advices)
    if !isnothing(getfield(a, field)) && !isnothing(getfield(b, field))
      @error "Multiple $field advices"
    elseif !isnothing(getfield(a, field))
      vals[field] = getfield(a, field)
    elseif !isnothing(getfield(b, field))
      vals[field] = getfield(b, field)
    end
  end

  Advices(vals)
end

include("advicenothing.jl")
include("advicebefore.jl")
include("adviceafterrunning.jl")
include("adviceafterthrowing.jl")
include("adviceafter.jl")
include("advicearound.jl")