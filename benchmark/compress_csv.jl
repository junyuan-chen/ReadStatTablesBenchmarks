# Compress the CSV files generated from Stata

using CSV

function main()
    fnames = ["1k_50", "10k_50", "10k_500"]
    for n in fnames
        f = CSV.File("data/stata_"*n*".csv")
        CSV.write("data/"*n*".csv.gz", f, compress=true)
    end
end

main()
