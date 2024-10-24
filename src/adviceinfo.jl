struct AdviceInfo
  advice::Advice
  pointcut::Pointcut
  param::JoinPointParam
end

mutable struct AdviceInfoSet

  debuginfo_pointcuts::Array{Pointcut}

  before::Array{AdviceInfo}
  around::Array{AdviceInfo}
  after_running::Array{AdviceInfo}
  after_throwing::Array{AdviceInfo}
  after::Array{AdviceInfo}

  function AdviceInfoSet(advices::Advices, pointcut::Pointcut, param::JoinPointParam)
    init(advice) = isnothing(advice) ? AdviceInfo[] : [AdviceInfo(advice, pointcut, param)]

    new(
      [pointcut],
      init(advices.before),
      init(advices.around),
      init(advices.after_running),
      init(advices.after_throwing),
      init(advices.after),
    )
  end
end

Base.convert(::Type{String}, ais::AdviceInfoSet) = begin
  "AdviceInfoSet($(join(["$field=$(getfield(ais, field))" for field in fieldnames(typeof(ais))],","))))"
end

Base.show(io::IO, ais::AdviceInfoSet) = print(io, convert(String, ais))


function appendadviceinfo!(aiset::AdviceInfoSet, advices::Advices, pointcut::Pointcut, param::JoinPointParam)::AdviceInfoSet

  for advicename in fieldnames(typeof(aiset))
    if advicename == :debuginfo_pointcuts
      push!(getfield(aiset, advicename), pointcut)
    else
      val = getfield(advices, advicename)
      if !isnothing(val)
        push!(getfield(aiset, advicename), AdviceInfo(val, pointcut, param))
      end
    end
  end

  aiset
end

function has_errorhandling(aiset::AdviceInfoSet)::Bool
  !isempty(aiset.after_throwing) ||
    !isempty(aiset.after)
end


function has_noadvice(aiset::AdviceInfoSet)::Bool
  isempty(aiset.before) &&
    isempty(aiset.around) &&
    isempty(aiset.after_running) &&
    isempty(aiset.after_throwing) &&
    isempty(aiset.after)
end

function need_preresolveargs(aiset::AdviceInfoSet)::Bool
  any(ai.advice isa Advice_WithArgs && need_preresolveargs(ai.param) for ai in aiset.before) ||
    any(ai.advice isa Advice_WithArgs && need_preresolveargs(ai.param) for ai in aiset.after_running) ||
    any(ai.advice isa Advice_WithArgs && need_preresolveargs(ai.param) for ai in aiset.after_throwing) ||
    any(ai.advice isa Advice_WithArgs && need_preresolveargs(ai.param) for ai in aiset.after)
end

function need_tmpresult(aiset::AdviceInfoSet)::Bool
  !isempty(aiset.after_running)
end
