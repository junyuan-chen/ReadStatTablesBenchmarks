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
        gen str1 vstr1_`i' = char(runiformint(65,122))
        gen str3 vstr3_`i' = char(runiformint(65,122)) + char(runiformint(65,122)) + ///
            char(runiformint(65,122))
        gen str15 vstr15_`i' = char(runiformint(65,122)) + char(runiformint(65,122)) + ///
            char(runiformint(65,122)) + char(runiformint(65,122)) + ///
            char(runiformint(65,122)) + char(runiformint(65,122)) + ///
            char(runiformint(65,122)) + char(runiformint(65,122)) + ///
            char(runiformint(65,122)) + char(runiformint(65,122)) + ///
            char(runiformint(65,122)) + char(runiformint(65,122)) + ///
            char(runiformint(65,122)) + char(runiformint(65,122)) + char(runiformint(65,122))
        gen str2 vpool`i' = char(runiformint(65,122)) + string(runiformint(0,9))
        gen int vdate`i' = runiformint(0, 32740)
        format vdate`i' %td
    }
end

gendata 1000 10
save data/1k_100.dta, replace
export delimited using data/stata_1k_100.csv, delimiter(",") replace

gendata 10000 10
save data/10k_100.dta, replace
export delimited using data/stata_10k_100.csv, delimiter(",") replace

gendata 10000 100
save data/10k_1k.dta, replace
export delimited using data/stata_10k_1k.csv, delimiter(",") replace
