function get_function_head(e)
  (head, args) = e |> ex_parse
  if head == :(::)
    get_function_head(args[1])
  elseif head == :call
    (args[1], args[2:end])
  else
    nothing
  end
end

function extract(e, parent_e=nothing, argindex=1)::Union{Nothing,ExprType,Array}

  if (parent_e |> ex_head) in (:function, :(=)) && argindex > 1 && ((result = get_function_head(parent_e |> ex_argsn(1))) |> !isnothing)  ## node is function body
    (fname, fargs) = result
    FunctionDefintionNode([], [(argindex, e)], parent_e, fname, fargs, e, parent_e |> ex_meta)
  else
    (head, args) = e |> ex_parse
    meta = e |> ex_meta
    args_wi = args |> enumerate |> collect

    if head == :module # Module definition
      ModuleNode([], args_wi[3:end], e, args[2], args[1], args[3], meta)
    elseif head == :struct # Struct definition
      if args[2] isa Symbol
        struct_name = args[2]
      elseif ex_isexpr(args[2], :(<:)) # Struct with type
        struct_name = args[2] |> ex_argsn(1)
      else
        @info "Mulformed :struct, $e"
        return nothing
      end
      StructNode([], args_wi[3:end], e, struct_name, args[1], args[3], meta)
    elseif head == :ref # Reference
      if length(args) == 1
        # Empty array declaration is ignored
      elseif length(args) > 1
        map(parse_ref(e)) do (name, referers)
          if isnothing(name) || name == :_
            IgnoreNode(get_siblings(referers))
          else
            ReferenceNode(get_siblings(referers), [], e, name, referers, meta)
          end
        end
      else
        @info "Mulformed :ref, $e"
        return nothing
      end
    elseif head == :(.) # Reference or parallel function call
      if args[2] isa QuoteNode
        map(parse_ref(e)) do (name, referers)
          if isnothing(name) || name == :_
            IgnoreNode(get_siblings(referers))
          else
            ReferenceNode(get_siblings(referers), [], e, name, referers, meta)
          end
        end
      else
        c1head = args[1] |> ex_head
        counter = 0
        map(parse_ref(args[1])) do (name, referers)
          siblings = (counter += 1) == 1 ? [get_siblings(referers)..., args[1:end]...] : get_siblings(referers)
          FunctionCallNode(siblings, [], e, name, referers, args[2:end], true, meta)
        end
      end
    elseif head == :(=) # Assignment
      if !isnothing(get_function_head(args[1])) # For function def
        return IgnoreNode([], args_wi[2:end])
      end

      c1head = args[1] |> ex_head
      if args[1] isa Symbol || c1head == :(::) || c1head == :(.) || (c1head == :ref && length(args[1] |> ex_args) > 1) || c1head == :tuple # Normal assignment
        counter = 0
        map(parse_ref(args[1])) do (name, referers)
          siblings = (counter += 1) == 1 ? [get_siblings(referers)..., args[2:end]...] : get_siblings(referers)
          #siblings = [get_siblings(referers)..., args[1:end]...]
          if isnothing(name) || name == :_
            IgnoreNode(siblings)
          else
            AssignmentNode(siblings, [], e, name, referers, args[2], meta)
          end
        end
      elseif c1head == :ref && length(args[1] |> ex_args) == 1
        # Empty array declaration is ignored
      else
        @info "Not supported assignment, $e"
      end
    elseif head in [:(:+=), :(:-=), :(:*=), :(:/=), :(://=), :(:\=), :(:^=), :(:%=), :(:|=), :(:&=), :(:⊻=), :(:<<=), :(:>>=), :(:>>>=)] # Assignment with operation
      counter = 0
      map(parse_ref(args[1])) do (name, referers)
        siblings = (counter += 1) == 1 ? [get_siblings(referers)..., args[1:end]...] : get_siblings(referers)
        op = Symbol(string(head)[1:end-1])
        ReferenceAssignmentNode(siblings, [], e, name, referers, args[2], op, meta)
      end
    elseif head == :call
      parent_head = parent_e |> ex_head
      if parent_head != :function
        c1head = args[1] |> ex_head

        counter = 0
        result = map(parse_ref(args[1])) do (name, referers)
          siblings = (counter += 1) == 1 ? [get_siblings(referers)..., args[1:end]...] : get_siblings(referers)
          FunctionCallNode(siblings, [], e, name, referers, args[2:end], false, meta)
        end

        if args[1] == :(|>) # Pipe operator
          result2 = map(parse_ref(args[3])) do (name, referers)
            FunctionCallNode([], [], e, name, referers, [args[2]], false, meta)
          end
          result = [result..., result2...]
        end
        result
      else
        nothing
      end
    elseif head == :(::)
      IgnoreNode(args)
    elseif head == :function #FIXME
      IgnoreNode([], args_wi[2:end]) # For function def
    elseif head == :macro # Macro definition
      c1head = args[1] |> ex_head
      c1args = args[1] |> ex_args
      if c1head == :call
        MacroDefintionNode([], args_wi[2:end], e, c1args[1], args[2], meta)
      else
        @info "Mulformed macro definition, $e"
      end
    elseif head == :(->)
      if ex_isexpr(args[1], :tuple) # multiple arguments
        c1args = args[1] |> ex_args
        FunctionDefintionNode([], args_wi[2:end], e, nothing, [c1args...], args[2], meta)
      else # single argument
        FunctionDefintionNode([], args_wi[2:end], e, nothing, [args[1]], args[2], meta)
      end
    elseif head == :for
      c1head = args[1] |> ex_head
      if c1head == :(=) # one range
        StdForNode([args[1]], args_wi[2:end], e, [args[1]], args[2], meta)
      elseif c1head == :block # multiple ranges
        c1args = args[1] |> ex_args
        StdForNode([args[1]], args_wi[2:end], e, c1args, args[2], meta)
      else
        @info "Not supported for loop, $e"
      end
    elseif head == :generator
      GeneratorNode(args[2:end], args_wi[2:end], e, args[2:end], args[1], meta)
    elseif head == :while # While loop
      IgnoreNode(args)
    elseif head == :do
      c1args = args[1] |> ex_args
      counter = 0
      map(parse_ref(c1args[1])) do (name, referers)
        siblings = (counter += 1) == 1 ? [get_siblings(referers)..., c1args[1:end]..., args[2]] : get_siblings(referers)
        FunctionCallNode(siblings, [], e, name, referers, [args[2], c1args[2:end]...], false, meta)
      end
    elseif head == :macrocall
      MacroCallNode(args[3:end], [], e, args[1], args[3:end], meta)
    elseif head == :string # InterpolationString
      IgnoreNode(args)
    elseif head in [:block, :kw, :if, :elseif, :continue, :(::), :(||), :(&&), :return, :vect, :vcat, :hcat, :row, :tuple, :comprehension, :curly, :(...), :const, :parameters]
      IgnoreNode(args)
    elseif head in [:using, :import, :abstract] || isnothing(head)
      nothing
    else
      @info "Not supported expression, $e"
    end
  end

end