using Printf

import DataFrames
import UniMZ
import Plots
Plots.pyplot()

include("util.jl")

path_ms = ARGS[1]
tasks = map(1:(length(ARGS)-2)÷2) do i
    (path=ARGS[i * 2], runs=eval(Meta.parse(ARGS[i * 2 + 1])))
end
path_out = ARGS[end]
mkpath(dirname(path_out))

fold_std = 4

n_scan = UniMZ.count_msx(path_ms, ".ms2")

V = UniMZ.build_ipv()

ps_basic = plot_basic_pre()
p_spec = Plots.plot()
p_pre = Plots.plot()
p_pep = Plots.plot()
for (idx, task) in enumerate(tasks)
    println(task.path)
    fold_hit = Inf
    df_hit = nothing
    d = map(task.runs) do run
        path_run = joinpath(task.path, string(run))
        n_spec = read_n_spec(path_run, :pFind)
        df = read_psm(path_run, :pFind)
        check_cluster_overlap!(df, V)
        fold = n_spec / n_scan
        if abs(fold - fold_std) < abs(fold_hit - fold_std)
            fold_hit, df_hit = fold, df
        end
        n_id_spec = size(df, 1)
        n_id_pre = size(unique(df, [:pep, :mod, :z]), 1)
        n_id_pep = size(unique(df, [:pep, :mod]), 1)
        @printf("%f:\t%d(%.2f×)\t=> %d(%.2f%%)\n", run, n_spec, fold, n_id_spec, n_id_spec / n_spec * 100)
        return [fold n_id_spec n_id_pre n_id_pep]
    end
    d = vcat(d...)
    label = basename(dirname(task.path))
    plot_basic(df_hit, label, idx, -18, ps_basic...)
    plot_number!(p_spec, d[:, 1], d[:, 2], label)
    plot_number!(p_pre, d[:, 1], d[:, 3], label; ylabel="#id. precursor")
    plot_number!(p_pep, d[:, 1], d[:, 4], label; ylabel="#id. peptide")
end

plot_basic_post(path_out, ps_basic...)

Plots.savefig(p_spec, "$(path_out)spec.pdf")
Plots.savefig(p_pre, "$(path_out)pre.pdf")
Plots.savefig(p_pep, "$(path_out)pep.pdf")
