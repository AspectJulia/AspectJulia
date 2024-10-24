abstract type Pointcut end

Base.show(io::IO, p::Pointcut) = print(io, convert(String, p))

Base.convert(::Type{LineNumberNode}, pc::Pointcut) = LineNumberNode(0, "AOP: $(convert(String, pc)) ##= $(pc.file):$(pc.line) =##")

Matcher = Union{Symbol,String}

include("default.jl")
include("xpath.jl")

include("assignment.jl")
include("assignmentM.jl")
include("callfunction.jl")
include("execfunction.jl")
include("object.jl")