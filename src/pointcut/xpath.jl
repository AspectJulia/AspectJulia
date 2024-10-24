
struct PointcutXPath <: Pointcut
  xpath::String
  file::String
  line::Int
end

@export_macrowithalias macro PointcutXPath(xpath)
  quote
    PointcutXPath($(esc(xpath)), $(string(__source__.file)), $(__source__.line))
  end
end

Base.convert(::Type{String}, pc::PointcutXPath) = "PointcutXPath(\"$(pc.xpath)\")"

function to_xpath(pc::PointcutXPath)
  pc.xpath
end

function validate(_::Type{PointcutXPath}, advices::Advices)
  true #TODO 
end