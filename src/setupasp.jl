
export setupasp

function extractmodulenames(exs::Array)
  [ex.args[2] for ex in exs if Meta.isexpr(ex, :module)]
end

function printinfo(modules::Array, newmodules::Array)
  modulenames = extractmodulenames(modules)
  newmodulenames = extractmodulenames(newmodules)

  if isempty(modulenames) && isempty(newmodulenames)
    @info "No modules are found."
  else

    modinfostr = ""

    if !isempty(modulenames)
      modinfostr *= "\n[Registered Original Modules]\n"
    end
    for modulename in modulenames
      modinfostr *= " - $modulename\n"
    end
    if !isempty(newmodulenames)
      modinfostr *= "\n[Registered New Modules]\n"
    end
    for modulename in newmodulenames
      modinfostr *= " - $modulename\n"
    end

    if isempty(modinfostr)
      @warn "No modules are found."
    else
      @info modinfostr
    end
  end

end

function parse(; filename::String)
  Meta.parse(read(filename, String), filename=filename)
end

function register(ex, scope::Module=Main)
  Base.eval(scope, ex)
end

function setupasp(aspects::Array{Aspect}; config::AspConfig=AspConfig(), scope::Module=Main, sym_prefix::Symbol=gensym())

  if !isvalid(config)
    @error "newname_prefix and newname_suffix must be specified if presere_rawmodule is true. config = $config"
  end

  function rename_module(v::Any)
    v
  end

  function rename_module(ex::Expr)
    if Meta.isexpr(ex, :module)
      Expr(:module, ex.args[1], newmodulename(ex.args[2], config), ex.args[3:end]...)
    else
      ex
    end
  end


  function simplifyblock(ex, skip=false)
    if !(ex isa Expr)
      ex
    elseif Meta.isexpr(ex, :block) && !skip && length(ex.args) == 1
      simplifyblock(ex.args[1], false)
    elseif Meta.isexpr(ex, :block) && length(ex.args) == 1 && Meta.isexpr(ex.args[1], :toplevel)
      new_args = [simplifyblock(a, false) for a in ex.args[1].args]
      Expr(:block, new_args...)
    elseif Meta.isexpr(ex, :module) || Meta.isexpr(ex, :macro)
      new_args = [simplifyblock(a, true) for a in ex.args]
      Expr(ex.head, new_args...)
    else
      new_args = [simplifyblock(a, false) for a in ex.args]
      Expr(ex.head, new_args...)
    end
  end


  weaveprocess(dir) = rename_module ∘ post_weave() ∘ simplifyblock ∘ (st -> emit(st, sym_prefix)) ∘ foldl((acc, aspect) -> weaver(aspect) ∘ acc, aspects, init=pre_weave(dir, config.preserve_linenumbernodes)) ∘ (config.preserve_linenumbernodes ? identity : Base.remove_linenums!)
  sanitizeprocess = sanitize() ∘ (config.preserve_linenumbernodes ? identity : Base.remove_linenums!)

  function asp_impl(ex::Expr, dir)

    @info "Weaver Working Directory: $dir"

    if Meta.isexpr(ex, :module)
      processed_ex = ex |> weaveprocess(dir)
      if config.preserve_module
        pure_ex = ex |> sanitizeprocess
        printinfo([pure_ex], [processed_ex])
        result = Expr(:toplevel, pure_ex, processed_ex)
      else
        printinfo(Expr[], [processed_ex])
        result = Expr(:toplevel, processed_ex)
      end
    elseif Meta.isexpr(ex, :block) || Meta.isexpr(ex, :toplevel)

      moduleexprs = filter(Base.Fix2(Meta.isexpr, :module), ex.args)
      modifiedmodules = map(weaveprocess(dir), moduleexprs)
      notmoduleexpr = map(weaveprocess(dir), filter(!Base.Fix2(Meta.isexpr, :module), ex.args))

      if config.preserve_module
        puremodules = map(sanitizeprocess, moduleexprs)
        printinfo(puremodules, modifiedmodules)
        result = Expr(:toplevel, puremodules..., modifiedmodules..., notmoduleexpr...)
      else
        printinfo(Expr[], modifiedmodules)
        result = Expr(:toplevel, modifiedmodules..., notmoduleexpr...)
      end

    else
      @error "asp func only accepts module, block or toplevel", ex.head
    end

    if config.debug_printgeneratedsyntaxtree
      debugstr = "\nGenerated Code:\n----------------------\n$result\n----------------------\n"
      @info debugstr
    end

    result
  end

  if config.toolsetname_header != :asp
    @info "toolsetname_header is \"$(config.toolsetname_header)\" used."
  end


  @info """

  - @$(config.toolsetname_header):\tWeave to the given code and register it to the current scope.
  - @$(config.toolsetname_header)_nr:\tWeave to the given code and return the syntax tree.
  - $(config.toolsetname_header)_src:\tWeave to the code in the given file and register it to the current scope.
  - $(config.toolsetname_header)_src_nr:\tWeave to the code in the given file and return the syntax tree.
  - $(config.toolsetname_header)_code:\tWeave to the given syntax tree and register it to the current scope.
  - $(config.toolsetname_header)_code_nr:\tWeave to the given syntax tree and return the syntax tree. 

  """

  Base.eval(scope, quote
    function $(Symbol(config.toolsetname_header, :_code))(ex::Expr)
      $register($asp_impl(ex, pwd()), $scope)
    end
    function $(Symbol(config.toolsetname_header, :_src))(path::AbstractString)
      $register($asp_impl(parse(filename=path), isabspath(path) ? dirname(path) : pwd()), $scope)
    end
    function $(Symbol(config.toolsetname_header, :_code_nr))(ex::Expr)
      $asp_impl(ex, pwd())
    end
    function $(Symbol(config.toolsetname_header, :_src_nr))(path::AbstractString)
      $asp_impl(parse(filename=path), isabspath(path) ? dirname(path) : pwd())
    end
    macro $(config.toolsetname_header)(ex)
      esc($asp_impl(ex, pwd()))
    end
    macro $(Symbol(config.toolsetname_header, :_nr))(ex)
      esc(Expr(:quote, $asp_impl(ex, pwd())))
    end
  end)
end
