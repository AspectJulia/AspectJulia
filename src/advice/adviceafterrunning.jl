@export_macrowithalias macro AdviceAfterRunning(func)
  quote
    Advices(after_running=Advice_NoArg($(esc(func))))
  end
end

@export_macrowithalias macro AdviceAfterRunningWithArgs(func)
  quote
    Advices(after_running=Advice_WithArgs($(esc(func))))
  end
end