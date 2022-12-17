using BenchmarkTools
using CairoMakie
using ColorSchemes: Paired_8
using DataFrames
using Printf

set_theme!()
update_theme!(Axis=(rightspinevisible=false, topspinevisible=false, spinewidth=0.7,
    xgridvisible=false, ygridvisible=false,
    titlefont="Helvetica", titlesize=14, titlegap=10, subtitlegap=4,
    xtickwidth=0.7, ytickwidth=0.7, xticksize=5, yticksize=5),
    font="Helvetica", fontsize=12, figure_padding=5,
    Legend=(patchsize=(10,10), padding=5, titlefont="Helvetica", fontsize=12,
        framewidth=0.7))

function collect_results!(df, r)
    for (f, g) in r
        for (nthd, tg) in g
            for (pkg, e) in tg
                push!(df.file, f)
                push!(df.nthd, nthd)
                push!(df.pkg, pkg)
                push!(df.time, e.time/1e9)
            end
        end
    end
end

const pkg_order = Dict(["ReadStatTables.jl", "ReadStat.jl", "pyreadstat", "haven", "pandas", "CSV.jl"].=>1:6)
const pkg_index = Dict(["ReadStatTables.jl", "ReadStat.jl", "pyreadstat", "haven", "pandas", "CSV.jl"].=>6:-1:1)
const file_order = Dict(["1k_50", "10k_50", "10k_500"].=>1:3)

function plot_results(df, title, fname, reltime::Bool=true, width=7.5, length=3.5)
    # Data need to be sorted first
    time = reltime ? df.time ./ df.time[2] : df.time
    res = 72 .* (width, length)
    fig = Figure(; resolution=res)
    pkgs = ["ReadStatTables.jl", "ReadStat.jl", "pyreadstat", "haven", "pandas", "CSV.jl (CSV File)"]
    ax = Axis(fig[1,1], yticks = (6:-1:1, pkgs), title = title, xlabel = "Relative Time")
    bar_lbls = [@sprintf("%.1f", x) for x in time]
    # bar_lbls[end-1:end] .*= " (CSV File)"
    colors = getindex.(Ref([Paired_8[2], Paired_8[2], Paired_8[8]]), df.nthd_index)
    barplot!(ax, df.pkg_index, time, dodge=df.nthd_index, color=colors,
        bar_labels=bar_lbls, direction=:x, label_size=11, width=0.95, dodge_gap=-0.1)
    xlims!(nothing, 1.1*maximum(time))
    hidexdecorations!(ax, label=false)
    elements = [PolyElement(polycolor=colors[i]) for i in 2:3]
    Legend(fig[2,1], elements, [string(df.nthd[2][end]), "1"],
        "Number of Threads ",
        tellheight=true, tellwidth=false, titleposition=:left, nbanks=2)
    rowgap!(fig.layout, Relative(0.05))
    save("results/$(fname).svg", fig, pt_per_unit=1)
    return fig
end

function main()
    results = BenchmarkTools.load("results/latest.json")[1]
    cols = (file=String[], nthd=String[], pkg=String[], time=Float64[])
    collect_results!(cols, results)
    df = DataFrame(cols)
    # Exclude multiprocess results of pyreadstat as they do not look right
    df = df[.~((df.pkg.=="pyreadstat").&(df.nthd.!="thread1")), :]
    df.nthd_index .= ifelse.(df.nthd .== "thread1", 1, 3)
    sort!(df, [:file, :pkg, :nthd_index], by=[x->file_order[x], x->pkg_order[x], identity])
    transform!(groupby(df, [:file, :pkg]), nrow=>:multi)
    df[df.multi.==1,:nthd_index] .= 2
    df.pkg_index = [pkg_index[n] for n in df.pkg]
    readstatatitle = "Reading Stata .dta File, Table of Size "
    plot_results(df[df.file.=="1k_50",:], readstatatitle * "1,000 × 50",
        "stata_1k_50_latest")
    plot_results(df[df.file.=="10k_50",:], readstatatitle * "10,000 × 50",
        "stata_10k_50_latest")
    plot_results(df[df.file.=="10k_500",:], readstatatitle * "10,000 × 500",
        "stata_10k_500_latest")
end

main()

