@export_macrowithalias macro AdviceAfterThrowing(func)
  quote
    Advices(after_throwing=Advice_NoArg($(esc(func))))
  end
end


@export_macrowithalias macro AdviceAfterThrowingWithArgs(func)
  quote
    Advices(after_throwing=Advice_WithArgs($(esc(func))))
  end
end
