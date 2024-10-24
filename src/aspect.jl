export Aspect

struct Aspect
  pointcut::Pointcut
  advices::Advices
  function Aspect(pointcut::Pointcut, advices::Advices)
    validate(typeof(pointcut), advices)
    new(pointcut, advices)
  end
end