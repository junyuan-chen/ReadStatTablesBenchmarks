# Run benchmarks and save results
# PythonCall should set up the Conda environment in the first run

using BenchmarkTools
using CSV
using PythonCall
using RCall
using ReadStat
using ReadStatTables

pyreadstat = pyimport("pyreadstat")
pd = pyimport("pandas")
@rimport haven

csv_single(p) = CSV.File(p, ntasks=1)

fnames = ["1k_100", "10k_100", "10k_1k"]
nsamples = [100, 100, 25]
single_pkgcmds = [
    "ReadStatTables.jl" => readstat,
    "ReadStat.jl" => read_dta,
    "pyreadstat" => pyreadstat.read_dta,
    "haven" => haven.read_dta,
    "Pandas" => pd.read_stata,
    "CSV.jl" => csv_single
]

suite = BenchmarkGroup()
suite["single_threaded"] = BenchmarkGroup()

for (pkg, cmd) in single_pkgcmds
    suite["single_threaded"][pkg] = BenchmarkGroup()
    for (n, nsam) in zip(fnames, nsamples)
        if pkg == "CSV.jl"
            # Unzip the gz files
            f = CSV.File("data/"*n*".csv.gz")
            path = "data/"*n*".csv"
            CSV.write(path, f)
        else
            path = "data/"*n*".dta"
        end
        suite["single_threaded"][pkg][n] = @benchmarkable $cmd($path) samples=nsam
    end
end

results = run(suite, verbose=true, seconds=300)
BenchmarkTools.save("results/latest.json", median(results))

