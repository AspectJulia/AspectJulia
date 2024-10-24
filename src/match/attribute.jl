
struct PointcutAttribution <: Pointcut
  pattern::Matcher
  file::String
  line::Int
  function PointcutAttribution(pattern::Matcher, file::String="", line::Int=0)
    new(pattern, file, line)
  end
end


@export_macrowithalias macro PointcutAttribution(pattern)
  quote
    PointcutAttribution($(esc(pattern)), $(string(__source__.file)), $(__source__.line))
  end
end

Base.convert(::Type{String}, pc::PointcutAttribution) = "PointcutAttribution(\"$(pc.pattern)\")"

struct CrawlerAttribution <: Crawler
  mode_function::Bool # true if the parent node is a function definition and the function have the attribute
  nth::Int64
  param::Nullable{JoinPointParam}
  function CrawlerAttribution(mode_function=false, nth=1, param=nothing)
    new(mode_function, nth, param)
  end
end

function create_statemachine(pc::PointcutAttribution)
  (
    initial=(_::Int64) -> CrawlerAttribution(),
    run=(v::Any, c::CrawlerAttribution) -> (
      nextf=(nth::Int64) -> begin
        mode_function = (v |> getmeta(pc.pattern) |> !isnothing) && ex_isfunctiondef(v)
        if mode_function
          f, args = ex_getfunctionparams(v |> ex_args |> getn(1))
          CrawlerAttribution(true, nth, JoinPointParamFunctionArgs(f, args))
        else
          CrawlerAttribution()
        end
      end,
      isend=(
        if (v |> getmeta(pc.pattern) |> !isnothing) && !ex_isfunctiondef(v)
          (true, JoinPointParamDefault())
        elseif c.mode_function && c.nth == 2
          (true, c.param)
        else
          (false, nothing)
        end)
    )
  )
end


# attrの位置によってはbeforeがサポートされない可能性があります。

function validate(_::Type{PointcutAttribution}, advices::Advices)
  if !isnothing(advices.before)
    @info "@attr may not support before depending on the position of attr macro."
  end

  if !isnothing(advices.before_execfunc)
    @info "@attr may not support before_execfunc depending on the position of attr macro."
  end

  if !isnothing(advices.before_call)
    @info "@attr may not support before_call depending on the position of attr macro."
  end

  if !isnothing(advices.around_execfunc)
    @info "@attr may not support around_execfunc depending on the position of attr macro."
  end

  true
end