function make_callfunc_arginfo_from_argtypes(argtypes)
  map(argtypes) do arg
    if arg isa NormalArgumentTypeWithDefault || arg isa KeywordArguentTypeWithDefault
      @error "Default value is not allowed in PointcutCallFunction"
    end
    argtype = arg isa NormalArgumentType ? (argtype=:normal,) : (argtype=:kw, name=arg.name)
    type = !isnothing(arg.type) ? (type=arg.type,) : nothing
    isvariadic = arg.isvariadic ? (isvariadic=true,) : nothing
    tuples = [argtype, type, isvariadic]
    merge(filter(!isnothing, tuples)...)
  end |> ls -> sort(ls, lt=(x, y) -> x.argtype < y.argtype)
end

