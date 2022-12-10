# Run benchmarks and save results
# PythonCall should set up the Conda environment in the first run

using BenchmarkTools
using CSV
using PythonCall
using RCall
using ReadStat
using ReadStatTables

const pyreadstat = pyimport("pyreadstat")
const pd = pyimport("pandas")
const haven = rimport("haven")

csv_single(p) = CSV.File(p, ntasks=1)

const fnames = ["1k_50", "10k_50", "10k_500"]
const nsamples = [500, 200, 100]
const single_pkgcmds = [
    "ReadStatTables.jl" => readstat,
    "ReadStat.jl" => read_dta,
    "pyreadstat" => pyreadstat.read_dta,
    "haven" => haven.read_dta,
    "pandas" => pd.read_stata,
    "CSV.jl" => csv_single
]

const suite = BenchmarkGroup()
suite["single_threaded"] = BenchmarkGroup()

for (n, nsam) in zip(fnames, nsamples)
    suite["single_threaded"][n] = BenchmarkGroup()
    for (pkg, cmd) in single_pkgcmds
        if pkg == "CSV.jl"
            # Unzip the gz files
            f = CSV.File("data/"*n*".csv.gz")
            path = "data/"*n*".csv"
            CSV.write(path, f)
        else
            path = "data/"*n*".dta"
        end
        suite["single_threaded"][n][pkg] = @benchmarkable $cmd($path) samples=nsam
    end
end

results = run(suite, verbose=true, seconds=300)
BenchmarkTools.save("results/latest.json", median(results))

