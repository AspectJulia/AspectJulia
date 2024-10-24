export AspConfig

struct AspConfig
  preserve_module::Bool
  newname_prefix::Union{Nothing,Symbol}
  newname_suffix::Union{Nothing,Symbol}
  preserve_linenumbernodes::Bool
  toolsetname_header::Symbol
  debug_printgeneratedsyntaxtree::Bool
  function AspConfig(;
    preserve_module::Bool=false,
    newname_prefix::Union{Nothing,Symbol}=nothing,
    newname_suffix::Union{Nothing,Symbol}=nothing,
    preserve_linenumbernodes::Bool=false,
    toolsetname_header::Symbol=:asp,
    debug_printgeneratedsyntaxtree::Bool=true,
  )
    new(preserve_module, newname_prefix, newname_suffix, preserve_linenumbernodes, toolsetname_header, debug_printgeneratedsyntaxtree)
  end
end

function isvalid(config::AspConfig)
  !config.preserve_module || !isnothing(config.newname_prefix) || !isnothing(config.newname_suffix)
end

function newmodulename(base::Symbol, config::AspConfig)
  Symbol(
    (isnothing(config.newname_prefix) ? () : (config.newname_prefix,))...,
    base,
    (isnothing(config.newname_suffix) ? () : (config.newname_suffix,))...)
end