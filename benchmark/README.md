To produce the benchmark results, follow the steps below:

- Resolve the Julia dependencies with Pkg using [`Project.toml`](../Project.toml).
- Resolve the Conda dependencies with CondaPkg.jl using [`CondaPkg.toml`](../CondaPkg.toml).
- Set up the R environment by running [`setupR.jl`](setupR.jl).
- Run [`benchmarks.jl`](benchmarks.jl) that produces the benchmark results.
- Run [`plotresults.jl`](plotresults.jl) for the figures and find all results in the [`results`](../results) directory.

The Stata .dta files in the [`data`](../data) directory
can be reproduced by running [`gendata.do`](gendata.do) in Stata.
Each dataset is also exported as CSV files.
These CSV files are compressed with [`compress_csv.jl`](compress_csv.jl).
