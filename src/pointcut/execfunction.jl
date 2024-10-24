struct PointcutExecutionFunction <: Pointcut
  pattern::Matcher
  args::Nullable{Any}
  file::String
  line::Int
  function PointcutExecutionFunction(pattern::Matcher, args=nothing, file::String="", line::Int=0)
    function make_execfunc_arginfo_from_argtypes(argtypes)
      map(argtypes) do arg
        argtype = arg isa NormalArgumentType ? (argtype=:normal,) : (argtype=:kw,)
        symbol = !isnothing(arg.symbol) ? (symbol=arg.symbol,) : nothing
        type = !isnothing(arg.type) ? (type=arg.type,) : nothing
        isvariadic = arg.isvariadic ? (isvariadic=true,) : nothing
        hasdefault = arg.hasdefault ? (hasdefault=true,) : nothing
        tuples = [argtype, symbol, type, isvariadic, default]
        merge(filter(!isnothing, tuples)...)
      end |> ls -> sort(ls, lt=(x, y) -> x.argtype < y.argtype)
    end
    argsdef = isnothing(args) ? nothing : (preprocess_argumenttype(args) |> make_execfunc_arginfo_from_argtypes)
    new(pattern, isnothing(args) ? nothing : argsdef, file, line)
  end
end

function execfunc_arginfo_to_str(arginfo)
  function tostr(arg)
    s_variadic = haskey(arg, :isvariadic) ? "..." : ""
    s_symbol = haskey(arg, :symbol) ? "$(arg.symbol)" : "*"
    s_type = haskey(arg, :type) ? "$(arg.type)" : "*"
    s_default = haskey(arg, :hasdefault) ? "=" : ""
    if haskey(arg, :symbol) || haskey(arg, :type)
      "$(s_symbol)::$(s_type)$(s_variadic)$(s_default)"
    else
      "*$(s_variadic)$(s_default)"
    end
  end

  normal_args_str = map(tostr, filter(a -> a.argtype == :normal, arginfo)) |> Base.Fix2(join, ", ")

  kw_args_str = map(tostr, filter(a -> a.argtype == :kw, arginfo)) |> Base.Fix2(join, ", ")

  "[" * normal_args_str * (length(kw_args_str) == 0 ? "" : "; ") * kw_args_str * "]"
end

Base.convert(::Type{String}, pc::PointcutExecutionFunction) = "PointcutExecutionFunction($(pc.pattern)" * (isnothing(pc.args) ? "" : ", $(execfunc_arginfo_to_str(pc.args))") * ")"

@export_macrowithalias macro PointcutExecutionFunction(pattern, args=nothing)
  quote
    PointcutExecutionFunction($(esc(pattern)), $(esc(args)), $(string(__source__.file)), $(__source__.line))
  end
end

function to_xpath(pc::PointcutExecutionFunction)
  if pc.pattern isa Symbol
    name = "@name='$(pc.pattern)'"
  else
    name = "contains(@name, '$(pc.pattern)')"
  end

  path = "//function[$name]"

  if !isnothing(pc.args)
    path *= "[@args='$(execfunc_arginfo_to_str(pc.args))']"
  end

  path
end
