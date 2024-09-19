using Printf
using Statistics

import CSV
import DataFrames
import UniMZ
import UniMZ: Plot, PyPlot, PyPlot.np, PyPlot.mpl, PyPlot.plt, PyPlot.plt_venn
import UniMZUtil
import UniMZUtil: pFind, pLink
import ProgressMeter: @showprogress
import PyCall: @py_str

ROOT = begin
    if Sys.isapple()
        "/Volumes/E-Disk/Data/PepPre/"
    elseif Sys.iswindows()
        joinpath(homedir(),  "OneDrive/Data/PepPre/")
    else
        ""
    end
end

Global_V = UniMZ.build_ipv()

calc_ion_pfind(df, M2, ε=20e-6) = begin
    tab_ele = pFind.read_element() |> NamedTuple
    tab_aa = map(x -> UniMZ.mass(x, tab_ele), pFind.read_amino_acid() |> NamedTuple)
    tab_mod = map(x -> x.mass, pFind.read_modification() |> NamedTuple)
    @info "Norm. num. of ions calculating"
    @showprogress map(eachrow(df)) do row
        m2 = M2[row.file][row.scan]
        ions = UniMZ.build_ions(m2.peaks, row.pep, row.mod, ε, tab_ele, tab_aa, tab_mod)
        ions = filter(i -> i.peak > 0, ions)
        return length(ions) / (length(row.pep))
    end
end

calc_ion_plink(df, M2, ε=20e-6) = begin
    tab_ele = pLink.read_element() |> NamedTuple
    tab_aa = map(x -> UniMZ.mass(x, tab_ele), pLink.read_amino_acid() |> NamedTuple)
    tab_mod = map(x -> x.mass, pLink.read_modification() |> NamedTuple)
    linkers = pLink.read_linker() |> NamedTuple
    @info "Norm. num. of ions calculating"
    @showprogress map(eachrow(df)) do row
        peps = (row.pep_a, row.pep_b)
        mods = (row.mod_a, row.mod_b)
        sites = (row.site_a, row.site_b)
        m2 = M2[row.file][row.scan]
        linker = linkers[row.linker]
        ionss = UniMZ.build_ions_crosslink(m2.peaks, peps, mods, linker, sites, ε, tab_ele, tab_aa, tab_mod)
        ionss = map(ions -> filter(i -> i.peak > 0, ions), ionss)
        return sum(length.(ionss)) / sum(length.(peps))
    end
end

calc_ion(df, M2, engine) = begin
    if engine == :pFind
        return calc_ion_pfind(df, M2)
    elseif engine == :pLink
        return calc_ion_plink(df, M2)
    end
end

check_cluster_overlap!(df, V=Global_V) = begin
    df.overlap .= false
    for g in DataFrames.groupby(df, [:file, :scan])
        for a in eachrow(g)
            mzs = UniMZ.ipv_mz(UniMZ.mh_to_mz(a.mh, a.z), a.z, V)
            for b in eachrow(g)
                a === b && continue
                mzs_ = UniMZ.ipv_mz(UniMZ.mh_to_mz(b.mh, b.z), b.z, V)
                if any(UniMZ.in_moe(mz, mz_, 10e-6) for mz in mzs for mz_ in mzs_)
                    a.overlap = true
                end
            end
        end
    end
end

check_center(df, M, ε=20e-6, V=Global_V) = begin
    map(eachrow(df)) do r
        any(mz -> UniMZ.in_moe(mz, M[r.file][r.scan].activation_center, ε), UniMZ.ipv_mz(r, V))
    end
end

check_inside(df, M) = begin
    map(eachrow(df)) do r
        abs(r.mz - M[r.file][r.scan].activation_center) <= M[r.file][r.scan].isolation_width / 2
    end
end

read_n_spec(path, engine) = begin
    if engine == :pFind
        return countlines(joinpath(path, "pFind", "pFind.spectra")) - 1
    elseif engine == :pLink
        return pLink.parse_n_spec(joinpath(path, "pLink", "reports", "example.summary.txt"))
    else
        UniMZ.read_all(countlines, joinpath(path, ""), ".mgf.csv") |> values |> vs -> sum(vs .- 1)
    end
end

read_n_id_spec(path, engine) = begin
    if engine == :pFind
        return countlines(joinpath(path, "pFind", "pFind-Filtered.spectra")) - 1
    elseif engine == :pLink
        return countlines(joinpath(path, "pLink", "reports", "example.filtered_cross-linked_spectra.csv")) - 1
    end
end

read_psm(path, engine) = begin
    if engine == :pFind
        return pFind.read_psm(joinpath(path, "pFind", "pFind-Filtered.spectra"))
    elseif engine == :pLink
        return pLink.read_psm(joinpath(path, "pLink", "reports", "example.filtered_cross-linked_spectra.csv"))
    end
end

read_psm_comet(path) = begin
    @info "reading " * path
    df = CSV.File(path; header=2, delim='\t') |> DataFrames.DataFrame
    df = DataFrames.rename(df, :plain_peptide => :pep, :modifications => :mod)
    df = df[df.sp_rank .== 1, :]
    df = sort(df, Symbol("e-value"))
    df.td .= :Unknown
    for r in eachrow(df)
        if all(p -> startswith(p, "REV_") || startswith(p, "decoy_"), split(r.protein, ','))
            r.td = :D
        else
            r.td = :T
        end
    end
    df.fdr = UniMZ.tda_fdr(df.td)
    df = df[df.fdr .<= 0.01, :]
    df = df[df.td .== :T, :]
    return df
end

read_psm_msfragger(path) = begin
    @info "reading " * path
    df = CSV.File(path; delim='\t') |> DataFrames.DataFrame
    df = df[df[!, "PeptideProphet Probability"] .>= 0.99, :]
    return df
end

read_pep_msfragger(path) = begin
    @info "reading " * path
    df = CSV.File(path; delim='\t') |> DataFrames.DataFrame
    df = df[df[!, "Probability"] .>= 0.99, :]
    return df
end
