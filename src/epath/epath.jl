import EzXML

include("referer.jl")

include("exprtype.jl")
include("node/ignore.jl")
include("node/for.jl")
include("node/object.jl")
include("node/reference.jl")
include("node/refassign.jl")
include("node/assign.jl")
include("node/function.jl")
include("node/call.jl")
include("node/macro.jl")
include("node/macrocall.jl")

include("extract.jl")
include("listepath.jl")
include("printepath.jl")
include("findpath.jl")