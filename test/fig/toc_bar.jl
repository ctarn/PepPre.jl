using Printf

import Makie, CairoMakie

include("util.jl")

xs = 1:4
ys = [72934, 89131, 112051, 119943]
b = 39794

f = ys ./ b

kw = (; strokewidth=2, strokecolor=:yellow)

fig = Makie.Figure(size=(300, 300), figure_padding=4)
ax = Makie.Axis(fig[1, 1]; ylabel="#PSM", xlabel="isolation window width (Th)", xticks=(vcat([0], xs), ["±$(x)" for x in vcat([1], xs)]))
Makie.barplot!(ax, xs, ys./b; bar_labels=[@sprintf("+%.0f%%", y/b * 100 - 100) for y in ys], color=["#00$(c^4)" for c in "BCDE"], kw...)
Makie.barplot!(ax, Int[], Int[]; label="PepPre", color="#00BBBB", kw...)
Makie.barplot!(ax, [0], [1]; bar_labels=["100%"], label="Baseline", color=:grey)
ax.xticksvisible = false
ax.yticksvisible = false
ax.yticklabelsvisible = false
ax.xgridvisible = false
ax.ygridvisible = false
ax.xminorgridvisible = false
ax.yminorgridvisible = false
ax.limits = (nothing, nothing, 0, 3.4)
Makie.axislegend(ax; position=:lt)
Makie.save(joinpath(ROOT, "fig", "PepPre_toc_bar.pdf"), fig)
display(fig)
