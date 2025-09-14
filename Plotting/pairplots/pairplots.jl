# this script plot pairplots of posteriors predicted by Neural likelihood estimator 
#
# Kai Li
# 29 May 2025

using CSV, Tables
using DataFrames

using Colors
using PairPlots
using Statistics
using CairoMakie
using LaTeXStrings
SW = CSV.read("SW.csv", DataFrame; delim = ',', header = false)

AWRI79650um = CSV.read("AWRI796_50um.csv", DataFrame; delim = ',', header = false)

AWRI796500um = CSV.read("AWRI796_500um.csv", DataFrame; delim = ',', header = false)

rename!(SW, ["nStar", "Pps", "Psp", "gamma", "pa"]) 
rename!(AWRI79650um, ["nStar", "Pps", "Psp", "gamma", "pa"])
rename!(AWRI796500um, ["nStar", "Pps", "Psp", "gamma", "pa"])

if AWRI796500um[1,1] == 0.5
    SW[:,1] = SW[:,1]*65000/60734
    AWRI796500um[:,1] = AWRI796500um[:,1]*100000/72059
    AWRI79650um[:,1] = AWRI79650um[:,1]*65000/40663
    println("nStar rescaled")
end

c1 = RGB(0.19,0.51,0.74);
c2 = RGB(0.90,0.33,0.05);
c3 = RGB(0.19,0.63,0.33);


fig = pairplot(
    PairPlots.Series(SW[10000:10:end,:], label="Simi White 50μM", color=c1, strokecolor=c1),
    PairPlots.Series(AWRI79650um, label="AWRI 796 50μM", color=c2, strokecolor=c2),
    PairPlots.Series(AWRI796500um[10000:10:end,:], label="AWRI 796 500μM", color=c3, strokecolor=c3),
    labels = Dict(
    # basic string
    :nStar => L"n^*",
    # Makie rich text
    :Pps => L"p_{ps}",
    # LaTeX String
    :Psp => L"p_{sp}",
    :gamma => L"\gamma",
    :pa => L"p_a",
    ),
    axis=(;
        nStar = (; lims = (;low=0, high=1),labelsize=36),
        Pps = (; lims = (;low=0, high=1),labelsize=36),
        Psp = (; lims = (;low=0, high=1),labelsize=36),
        gamma = (; lims = (;low=0, high=1),labelsize=36),
        pa = (; lims = (;low=0, high=1),labelsize=36),
    ), 
)

fig.content[16].labelsize = 36
fig.content[16].framevisible = false
fig.content[16].linewidth = 10
fig.layout[2,5] = fig.content[16]
fig

# save("pairplot_combined.pdf",fig)

fig = pairplot(
    AWRI79650um  => (
        PairPlots.HexBin(colormap=Makie.cgrad([:transparent, c2])),
        # PairPlots.Scatter(color=c2),
        PairPlots.Contour(color=c2),
        PairPlots.MarginHist(color=c2),
        PairPlots.MarginQuantileText(color=:black),
        PairPlots.MarginQuantileLines(color=:black),
        PairPlots.MarginDensity()
    ),
    labels = Dict(
    # basic string
    :nStar => L"n^*",
    # Makie rich text
    :Pps => L"p_{ps}",
    # LaTeX String
    :Psp => L"p_{sp}",
    :gamma => L"\gamma",
    :pa => L"p_a"
    ),
    axis=(;
        nStar = (; lims = (;low=0, high=1),labelsize=36),
        Pps = (; lims = (;low=0, high=1),labelsize=36),
        Psp = (; lims = (;low=0, high=1),labelsize=36),
        gamma = (; lims = (;low=0, high=1),labelsize=36),
        pa = (; lims = (;low=0, high=1),labelsize=36),
    ),
)

# save("pairplot_AWRI796_50um.pdf",fig)

fig = Figure()

fig = pairplot(
    AWRI796500um[10000:10:end,:]  => (
        PairPlots.HexBin(colormap=Makie.cgrad([:transparent, c3])),
        # PairPlots.Scatter(color=c3),
        PairPlots.Contour(color=c3),
        PairPlots.MarginHist(color=c3),
        PairPlots.MarginQuantileText(color=:black),
        PairPlots.MarginQuantileLines(color=:black),
        PairPlots.MarginDensity()
    ),
    labels = Dict(
    # basic string
    :nStar => L"n^*",
    # Makie rich text
    :Pps => L"p_{ps}",
    # LaTeX String
    :Psp => L"p_{sp}",
    :gamma => L"\gamma",
    :pa => L"p_a"
    ),
    axis=(;
        nStar = (; lims = (;low=0, high=1),labelsize=36),
        Pps = (; lims = (;low=0, high=1),labelsize=36),
        Psp = (; lims = (;low=0, high=1),labelsize=36),
        gamma = (; lims = (;low=0, high=1),labelsize=36),
        pa = (; lims = (;low=0, high=1),labelsize=36),
    ),
)

# save("pairplot_AWRI796_500um.pdf",fig)

fig = Figure()

fig = pairplot(
    SW[10000:10:end,:]  => (
        PairPlots.HexBin(colormap=Makie.cgrad([:transparent, c3])),
        # PairPlots.Scatter(color=c3),
        PairPlots.Contour(color=c3),
        PairPlots.MarginHist(color=c3),
        PairPlots.MarginQuantileText(color=:black),
        PairPlots.MarginQuantileLines(color=:black),
        PairPlots.MarginDensity()
    ),
    labels = Dict(
    # basic string
    :nStar => L"n^*",
    # Makie rich text
    :Pps => L"p_{ps}",
    # LaTeX String
    :Psp => L"p_{sp}",
    :gamma => L"\gamma",
    :pa => L"p_a"
    ),
    axis=(;
        nStar = (; lims = (;low=0, high=1),labelsize=36),
        Pps = (; lims = (;low=0, high=1),labelsize=36),
        Psp = (; lims = (;low=0, high=1),labelsize=36),
        gamma = (; lims = (;low=0, high=1),labelsize=36),
        pa = (; lims = (;low=0, high=1),labelsize=36),
    ),
)

# save("pairplot_SW_50um.pdf",fig)