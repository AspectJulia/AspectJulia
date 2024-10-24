struct PointcutObject <: Pointcut
  pattern::Matcher
  pctype::Symbol
  flag::Bool # if object is module, true if not bare module. if object is struct, true if mutable struct 
  file::String
  line::Int
end

Base.convert(::Type{String}, pc::PointcutObject) = pc.pctype == :module ? "PointcutModule(\"$(pc.pattern)\", bare = $(!pc.flag))" : "PointcutStruct(\"$(pc.pattern)\", mutable = $(pc.flag))"

@export_macrowithalias macro PointcutModule(pattern, notbare=true)
  quote
    PointcutObject($(esc(pattern)), :module, $(esc(notbare)), $(string(__source__.file)), $(__source__.line))
  end
end

@export_macrowithalias macro PointcutStruct(pattern, mutable=false)
  quote
    PointcutObject($(esc(pattern)), :struct, $(esc(mutable)), $(string(__source__.file)), $(__source__.line))
  end
end


function to_xpath(pc::PointcutExecutionFunction)
  if pc.pattern isa Symbol
    name = "@name='$(pc.pattern)'"
  else
    name = "contains(@name, '$(pc.pattern)')"
  end

  if pc.pctype == :module
    path = "//module[$name]"
    if !(pc.flag)
      path *= "[@bare]"
    end
  else
    path = "//struct[$name]"
    if pc.flag
      path *= "[@mutable]"
    end
  end
  path
end

function validate(::Type{PointcutObject}, advices::Advices)
  if !isnothing(advices.before)
    @error "Object pointcut does not support before advice"
  end
  if !isnothing(advices.after)
    @error "Object pointcut does not support after advice"
  end
  if !isnothing(advices.after_throwing)
    @error "Object pointcut does not support after_throwing advice"
  end
  if !isnothing(advices.after_running)
    @error "Object pointcut does not support after_running advice"
  end
  true
end
