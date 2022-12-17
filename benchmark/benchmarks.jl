# Run benchmarks and save results
# PythonCall should set up the Conda environment in the first run

using BenchmarkTools
using CSV
using PythonCall
using RCall
using ReadStat
using ReadStatTables

const pyrs = pyimport("pyreadstat")
const pd = pyimport("pandas")
const haven = rimport("haven")

csv1(p) = CSV.File(p, ntasks=1)
readstat1(p) = readstat(p, ntasks=1)

readstat4(p) = readstat(p, ntasks=4)
pyrs4(p) = pyrs.read_file_multiprocessing(pyrs.read_dta, p, num_processes=4)
csv4(p) = CSV.File(p, ntasks=4)

readstat8(p) = readstat(p, ntasks=8)
pyrs8(p) = pyrs.read_file_multiprocessing(pyrs.read_dta, p, num_processes=8)
csv8(p) = CSV.File(p, ntasks=8)

const fnames = ["1k_50", "10k_50", "10k_500"]
const nsamples = [500, 200, 100]
const pkgcmds1 = [
    "ReadStatTables.jl" => readstat1,
    "ReadStat.jl" => read_dta,
    "pyreadstat" => pyrs.read_dta,
    "haven" => haven.read_dta,
    "pandas" => pd.read_stata,
    "CSV.jl" => csv1
]
const pkgcmds4 = [
    "ReadStatTables.jl" => readstat4,
    # pyreadstat is ommitted as the multiprocess version is very slow on small files
    "CSV.jl" => csv4
]
const pkgcmds8 = [
    "ReadStatTables.jl" => readstat8,
    "pyreadstat" => pyrs8,
    "CSV.jl" => csv8
]

const suite = BenchmarkGroup()
suite["1k_50"] = BenchmarkGroup()
suite["10k_50"] = BenchmarkGroup()
suite["10k_500"] = BenchmarkGroup()

for (n, nsam) in zip(fnames, nsamples)
    suite[n]["thread1"] = BenchmarkGroup()
    for (pkg, cmd) in pkgcmds1
        if pkg == "CSV.jl"
            # Unzip the gz files
            f = CSV.File("data/"*n*".csv.gz")
            path = "data/"*n*".csv"
            CSV.write(path, f)
        else
            path = "data/"*n*".dta"
        end
        suite[n]["thread1"][pkg] = @benchmarkable $cmd($path) samples=nsam
    end
    if n == "10k_500"
        suite[n]["thread8"] = BenchmarkGroup()
        for (pkg, cmd) in pkgcmds8
            path = pkg == "CSV.jl" ? "data/"*n*".csv" : "data/"*n*".dta"
            suite[n]["thread8"][pkg] = @benchmarkable $cmd($path) samples=nsam
        end
    else
        suite[n]["thread4"] = BenchmarkGroup()
        for (pkg, cmd) in pkgcmds4
            path = pkg == "CSV.jl" ? "data/"*n*".csv" : "data/"*n*".dta"
            suite[n]["thread4"][pkg] = @benchmarkable $cmd($path) samples=nsam
        end
    end
end

results = run(suite, verbose=true, seconds=300)
BenchmarkTools.save("results/latest.json", median(results))

