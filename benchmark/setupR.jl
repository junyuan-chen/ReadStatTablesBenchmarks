# Configure RCall after installing R via CondaPkg.jl

using Pkg

# Use the R installed by CondaPkg.jl
ENV["R_HOME"] = (@__DIR__)*"/../.CondaPkg/env/lib/R"
Pkg.build("RCall")
