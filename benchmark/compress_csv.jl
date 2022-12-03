# Compress the CSV files generated from Stata

using CSV

function main()
    fnames = ["1k_100", "10k_100", "10k_1k"]
    for n in fnames
        f = CSV.File("data/stata_"*n*".csv")
        CSV.write("data/"*n*".csv.gz", f, compress=true)
    end
end

main()
