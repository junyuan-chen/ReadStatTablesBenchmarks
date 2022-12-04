using BenchmarkTools
using CairoMakie
using DataFrames
using Printf

set_theme!()
update_theme!(Axis=(rightspinevisible=false, topspinevisible=false, spinewidth=0.7,
    xgridvisible=false, ygridvisible=false,
    titlefont="Helvetica", titlesize=14, titlegap=12, subtitlegap=4,
    xtickwidth=0.7, ytickwidth=0.7, xticksize=5, yticksize=5),
    font="Helvetica", fontsize=12, figure_padding=5)

function collect_results!(df, r)
    for (n, g) in r
        for (pkg, e) in g
            push!(df.file, n)
            push!(df.pkg, pkg)
            push!(df.time, e.time/1e9)
        end
    end
end

const pkg_order = Dict(["ReadStatTables.jl", "ReadStat.jl", "pyreadstat", "haven", "pandas", "CSV.jl"].=>1:6)
const file_order = Dict(["1k_100", "10k_100", "10k_1k"].=>1:3)

function plot_singles(df, title, subtitle, fname, reltime::Bool=true, width=6, length=3.5)
    # Data need to be sorted first
    time = reltime ? df.time ./ df.time[1] : df.time
    res = 72 .* (width, length)
    fig = Figure(; resolution=res)
    pkgs = ["ReadStatTables.jl", "ReadStat.jl", "pyreadstat", "haven", "pandas", "CSV.jl"]
    ax = Axis(fig[1,1], yticks = (6:-1:1, pkgs),
        title = title, subtitle=subtitle, xlabel = "Relative Time", ylabel = "Package")
    bar_lbls = [@sprintf("%.2f", x) for x in time]
    bar_lbls[end] *= " (CSV File)"
    barplot!(ax, 6:-1:1, time, bar_labels=bar_lbls, direction=:x, label_size=11)
    xlims!(nothing, 1.1*maximum(time))
    save("results/$(fname).svg", fig, pt_per_unit=1)
    return fig
end

function main()
    results = BenchmarkTools.load("results/latest.json")[1]
    singles = (file=String[], pkg=String[], time=Float64[])
    collect_results!(singles, results["single_threaded"])
    singles = DataFrame(singles)
    sort!(singles, [:pkg, :file], by=[x->pkg_order[x], x->file_order[x]])
    readstatatitle = "Reading Stata .dta File"
    plot_singles(singles[singles.file.=="1k_100",:],
        readstatatitle, "Table of Size 1,000 × 100, Single-Threaded",
        "stata_1k_100_latest")
    plot_singles(singles[singles.file.=="10k_100",:],
        readstatatitle, "Table of Size 10,000 × 100, Single-Threaded",
        "stata_10k_100_latest")
    plot_singles(singles[singles.file.=="10k_1k",:],
        readstatatitle, "Table of Size 10,000 × 1,000, Single-Threaded",
        "stata_10k_1k_latest")
end

main()

