@export_macrowithalias macro AdviceAround(func)
  quote
    Advices(around=Advice_Replace($(esc(func))))
  end
end

@export_macrowithalias macro AdviceAppendFront(func)
  quote
    Advices(around=Advice_AppendFront($(esc(func))))
  end
end

@export_macrowithalias macro AdviceAppendBack(func)
  quote
    Advices(around=Advice_AppendBack($(esc(func))))
  end
end
