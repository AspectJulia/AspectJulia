struct PointcutAssignmentM <: Pointcut
  pattern::Matcher
  jptype::Symbol
  file::String
  line::Int
  function PointcutAssignmentM(pattern::Matcher, jptype::Symbol, file::String="", line::Int=0)
    new(pattern, jptype, file, line)
  end
end

Base.convert(::Type{String}, pc::PointcutAssignmentM) = pc.jptype == :ref ? "PointcutAssignmentArray(\"$(pc.pattern)\")" : "PointcutAssignmentMutableStruct(\"$(pc.pattern)\")"

@export_macrowithalias macro PointcutAssignmentArray(pattern)
  quote
    PointcutAssignmentM($(esc(pattern)), :ref, $(string(__source__.file)), $(__source__.line))
  end
end

@export_macrowithalias macro PointcutAssignmentStruct(pattern)
  quote
    PointcutAssignmentM($(esc(pattern)), :field, $(string(__source__.file)), $(__source__.line))
  end
end

@export_macrowithalias macro PointcutMutableAssignmentStruct(pattern)
  quote
    PointcutAssignmentM($(esc(pattern)), :field, $(string(__source__.file)), $(__source__.line))
  end
end

function to_xpath(pc::PointcutAssignmentM)
  if pc.pattern isa Symbol
    name = "@name='$(pc.pattern)'"
  else
    name = "contains(@name, '$(pc.pattern)')"
  end
  if pc.jptype == :ref
    "//assign[$name][@ref='%[]']"
  else
    "//assign[$name][contains(@ref, '%.')]"
  end
end
