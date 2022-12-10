* Generate data files for benchmarking
* Stata working directory should be at the root of the repository
version 17
clear

cap program drop gendata
program gendata
    clear
    args nrow ncol
    set seed 1234
    set obs `nrow'
    * Each iteration generates 10 columns
    forvalues i = 1/`ncol' {
        gen byte vbyte`i' = runiformint(-127, 100)
        gen int vint`i' = runiformint(-32767, 32740)
        gen long vlong`i' = runiformint(-2147483647, 2147483620)
        gen float vfloat`i' = runiform(-1000, 1000)
        gen double vdouble`i' = runiform(-1000, 1000)
        gen int vdate`i' = runiformint(0, 32740)
        format vdate`i' %td
        gen float vtime`i' = runiformint(-1e12, 1e12)
        format vtime`i' %tc
        gen str32 vpool`i' = char(runiformint(65,84)) + string(runiformint(0,9))
        forvalues k = 1/4 {
            replace vpool`i' = vpool`i' + vpool`i'
        }
        gen str5 vstr5_`i' = char(runiformint(65,122)) + char(runiformint(65,122)) + ///
            char(runiformint(65,122)) + char(runiformint(65,122)) + char(runiformint(65,122))
        gen str40 vstr40_`i' = vstr5_`i'
        forvalues k = 1/3 {
            replace vstr40_`i' = vstr40_`i' + vstr40_`i'
        }
    }
end

gendata 1000 5
save data/1k_50.dta, replace
export delimited using data/stata_1k_50.csv, delimiter(",") replace

gendata 10000 5
save data/10k_50.dta, replace
export delimited using data/stata_10k_50.csv, delimiter(",") replace

gendata 10000 50
save data/10k_500.dta, replace
export delimited using data/stata_10k_500.csv, delimiter(",") replace
