module AspectJulia

import Base: @v_str
const version = v"0.1.0"

import Logging
import Dates

function timed_metafmt(level, _module, group, id, file, line)
  color, prefix, suffix =
    Logging.default_metafmt(level, _module, group, id, file, line)
  color, "$(Dates.now()): $prefix", suffix
end

Logging.global_logger(Logging.ConsoleLogger(meta_formatter=Logging.default_metafmt))



include("util.jl")

include("advice/advice.jl")

include("match/matchutil.jl")

include("pointcut/pointcut.jl")

include("config.jl")

include("ajnode.jl")


include("joinpoint/joinpoint.jl")

include("adviceinfo.jl")

include("customnode/customnode.jl")


include("aspect.jl")


include("epath/epath.jl")

include("emit.jl")
include("weaver.jl")


include("setupasp.jl")
include("stubasp.jl")




# include("match/argument.jl")
# 

# include("match/default.jl")

# include("match/execfunction.jl")
# include("match/callfunction.jl")
# include("match/assignment.jl")
# include("match/referencem.jl")
# include("match/refassignment.jl")
# include("match/object.jl")
# include("match/attribute.jl")



include("exprutil/exprutil.jl")


end