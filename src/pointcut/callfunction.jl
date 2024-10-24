
struct PointcutCallFunction <: Pointcut
  pattern::Matcher
  argc::Nullable{Int}
  file::String
  line::Int
  function PointcutCallFunction(pattern::Matcher, argc::Nullable{Int}=nothing, file::String="", line::Int=0)
    new(pattern, argc, file, line)
  end
end

Base.convert(::Type{String}, pc::PointcutCallFunction) = "PointcutCallFunction($(pc.pattern)" * (isnothing(pc.argc) ? "" : "argc=$(pc.argc)") * ")"

@export_macrowithalias macro PointcutCallFunction(pattern)
  quote
    PointcutCallFunction($(esc(pattern)), nothing, $(string(__source__.file)), $(__source__.line))
  end
end

function to_xpath(pc::PointcutCallFunction)
  if pc.pattern isa Symbol
    name = "@name='$(pc.pattern)'"
  else
    name = "contains(@name, '$(pc.pattern)')"
  end

  path = "//call[$name]"

  if !isnothing(pc.args)
    path *= "[@args='$(pc.argc)']"
  end

  path

end

