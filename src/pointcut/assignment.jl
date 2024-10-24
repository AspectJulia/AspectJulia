struct PointcutAssignment <: Pointcut
  pattern::Matcher
  file::String
  line::Int
  function PointcutAssignment(pattern::Matcher, file::String="", line::Int=0)
    new(pattern, file, line)
  end
end

Base.convert(::Type{String}, pc::PointcutAssignment) = "PointcutAssignment(\"$(pc.pattern)\"" * (isnothing(pc.type) ? "" : "::$(pc.type)") * ")"

@export_macrowithalias macro PointcutAssignment(pattern, type=nothing)
  quote
    PointcutAssignment($(esc(pattern)), $(string(__source__.file)), $(__source__.line))
  end
end

function to_xpath(pc::PointcutAssignment)
  if pc.pattern isa Symbol
    name = "@name=\"$(pc.pattern)\""
  else
    name = "contains(@name, \"$(pc.pattern)\")"
  end

  "//assign[$name]"
end

function validate(_::Type{PointcutAssignment}, advices::Advices)
  if !isnothing(advices.after_throwing)
    @error "after_throwing advice is not allowed for PointcutAssignment"
  end

  if !isnothing(advices.after)
    @error "after advice is not allowed for PointcutAssignment"
  end


  if advices.before isa Advice_WithArgs
    @warn "before advice with arguments is not recommended for PointcutAssignment, because of high overhead."
  end

  if advices.after_running isa Advice_WithArgs
    @warn "after_running advice with arguments is not recommended for PointcutAssignment, because of high overhead."
  end

  true
end
