@export_macrowithalias macro AdviceBefore(func)
  quote
    Advices(before=Advice_NoArg($(esc(func))))
  end
end

@export_macrowithalias macro AdviceBeforeWithArgs(func)
  quote
    Advices(before=Advice_WithArgs($(esc(func))))
  end
end