using Printf

import DataFrames
import UniMZ
import Plots
Plots.pyplot()

include("util.jl")

path_ms = ARGS[1]
path_fasta = ARGS[2]
tasks = map(1:(length(ARGS)-3)÷2) do i
    (path=ARGS[i * 2 + 1], runs=eval(Meta.parse(ARGS[i * 2 + 2])))
end
path_out = ARGS[end]
mkpath(dirname(path_out))

fold_std = 4

fasta = UniMZ.read_fasta(path_fasta)
n_scan = UniMZ.count_msx(path_ms, ".ms2")

V = UniMZ.build_ipv()

ps_basic = plot_basic_pre()
p_spec = (n=Plots.plot(), fdr=Plots.plot())
p_pre = (n=Plots.plot(), fdr=Plots.plot())
p_pep = (n=Plots.plot(), fdr=Plots.plot())
ps_overlap = map(_ -> Plots.plot(), tasks)
for (idx, task) in enumerate(tasks)
    println(task.path)
    fold_hit = Inf
    df_hit = nothing
    d = map(task.runs) do run
        path_run = joinpath(task.path, string(run))
        n_spec = read_n_spec(path_run, :pLink)
        df = read_psm(path_run, :pLink)
        df.ist = check_prot([df.prot_a, df.prot_b], getfield.(fasta, :id))
        check_cluster_overlap!(df, V)
        fold = n_spec / n_scan
        if abs(fold - fold_std) < abs(fold_hit - fold_std)
            fold_hit, df_hit = fold, df
        end
        # spectrum level
        n_id_spec = size(df, 1)
        fdr_spec = (1 - sum(df.ist) / n_id_spec) * 100
        o, o_f = sum(df.overlap), sum(df.overlap .& .!df.ist)
        # precursor level
        df = unique(df, [:pep_a, :mod_a, :site_a, :pep_b, :mod_b, :site_b, :z])
        n_id_pre = size(df, 1)
        fdr_pre = (1 - sum(df.ist) / n_id_pre) * 100
        # peptide level
        df = unique(df, [:pep_a, :mod_a, :site_a, :pep_b, :mod_b, :site_b])
        n_id_pep = size(df, 1)
        fdr_pep = (1 - sum(df.ist) / n_id_pep) * 100
        @printf("%f:\t%d(%.2f×)\t=> %d(%.2f%%)\tFDR=%.2f%%\n", run, n_spec, fold, n_id_spec, n_id_spec / n_spec * 100, fdr_spec)
        return [fold n_id_spec fdr_spec n_id_pre fdr_pre n_id_pep fdr_pep o o_f]
    end
    d = vcat(d...)
    label = basename(dirname(task.path))
    plot_basic(df_hit, label, idx, -9, ps_basic...)
    plot_number!(p_spec.n, d[:, 1], d[:, 2], label; xlabel="")
    plot_fdr!(p_spec.fdr, d[:, 1], d[:, 3], label; legend=:none)
    plot_number!(p_pre.n, d[:, 1], d[:, 4], label; xlabel="", ylabel="#id. precursor")
    plot_fdr!(p_pre.fdr, d[:, 1], d[:, 5], label; legend=:none)
    plot_number!(p_pep.n, d[:, 1], d[:, 6], label; xlabel="", ylabel="#id. peptide pair")
    plot_fdr!(p_pep.fdr, d[:, 1], d[:, 7], label; legend=:none)
    plot_overlap!(ps_overlap[idx], d[:, 1], d[:, 8], d[:, 9], label)
end

plot_basic_post(path_out, ps_basic...)

for (p, level) in [(p_spec, "spec"), (p_pre, "pre"), (p_pep, "pep")]
    p = Plots.plot(p.n, p.fdr; layout=Plots.grid(2, 1, heights=[0.7, 0.3]))
    Plots.savefig(p, "$(path_out)$(level).pdf")
end

p_overlap = Plots.plot(ps_overlap...; layout=Plots.grid(length(ps_overlap), 1), link=:all)
Plots.savefig(p_overlap, "$(path_out)overlap.pdf")
