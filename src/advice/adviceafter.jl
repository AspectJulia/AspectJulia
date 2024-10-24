@export_macrowithalias macro AdviceAfter(func)
  quote
    Advices(after=Advice_NoArg($(esc(func))))
  end
end

@export_macrowithalias macro AdviceAfterWithArgs(func)
  quote
    Advices(after=Advice_WithArgs($(esc(func))))
  end
end
