include("util.jl")

D = Dict(
    :ZH2 => Dict(
        :id => "Zubarev-Human-2",
        :isolation_width => 2,
        :engine => :pFind,
        :tasks => [
            Dict(:id => "PepPre@2", :run => 4.0),
            Dict(:id => "pParse@2", :run => -0.7),
            Dict(:id => "RawConverter", :run => 1),
            Dict(:id => "Monocle", :run => 1),
            Dict(:id => "Decon2LS", :run => 1),
            Dict(:id => "RAPID", :run => 1),
            Dict(:id => "MaxQuant", :run => 1),
            Dict(:id => "Dinosaur", :run => 1),
            Dict(:id => "PointIso", :run => 1),
            Dict(:id => "EnumInst", :run => 4),
            Dict(:id => "EnumIW", :run => 1),
            Dict(:id => "EnumEx", :run => 1),
        ],
    ),
    :ZH8 => Dict(
        :id => "Zubarev-Human-8",
        :isolation_width => 8,
        :engine => :pFind,
        :tasks => [
            Dict(:id => "PepPre@8", :run => 4.0),
            Dict(:id => "pParse@8", :run => 0.2),
            Dict(:id => "RawConverter", :run => 1),
            Dict(:id => "Monocle", :run => 1),
            Dict(:id => "Decon2LS", :run => 1),
            Dict(:id => "RAPID", :run => 1),
            Dict(:id => "MaxQuant", :run => 1),
            Dict(:id => "Dinosaur", :run => 1),
            Dict(:id => "PointIso", :run => 1),
            Dict(:id => "EnumInst", :run => 4),
            Dict(:id => "EnumIW", :run => 1),
            Dict(:id => "EnumEx", :run => 1),
        ],
    ),
    :DD => Dict(
        :id => "Dong-DSS-1.6",
        :isolation_width => 1.6,
        :engine => :pLink,
        :tasks => [
            Dict(:id => "PepPre", :run => 4.0),
            Dict(:id => "pParse", :run => -0.8),
            Dict(:id => "RawConverter", :run => 1),
            Dict(:id => "Monocle", :run => 1),
            Dict(:id => "Decon2LS", :run => 1),
            Dict(:id => "RAPID", :run => 1),
            Dict(:id => "MaxQuant", :run => 1),
            Dict(:id => "Dinosaur", :run => 1),
            Dict(:id => "PointIso", :run => 1),
            Dict(:id => "EnumInst", :run => 4),
            Dict(:id => "EnumIW", :run => 1),
            Dict(:id => "EnumEx", :run => 1),
        ],
    ),
)

zs = [
    ("1+", x -> x == 1)
    ("2+", x -> x == 2)
    ("3+", x -> x == 3)
    ("4+", x -> x == 4)
    ("5+", x -> x == 5)
    ("≥ 6+", x -> x >= 6)
 ]

ms = [
    ("[0, 1000)", x -> 0 <= x < 1000)
    ("[1000, 1500)", x -> 1000 <= x < 1500)
    ("[1500, 2000)", x -> 1500 <= x < 2000)
    ("[2000, 2500)", x -> 2000 <= x < 2500)
    ("[2500, 3000)", x -> 2500 <= x < 3000)
    ("[3000, +∞)", x -> 3000 <= x)
]

ns = [
    ("≥ 1", x -> x >= 1)
    ("≥ 2", x -> x >= 2)
    ("≥ 3", x -> x >= 3)
    ("≥ 4", x -> x >= 4)
    ("≥ 5", x -> x >= 5)
    ("≥ 6", x -> x >= 6)
]

for d in [D[:ZH2], D[:ZH8], D[:DD]]
    M = UniMZ.read_all(UniMZ.read_ms2, joinpath(ROOT, "data", d[:id], ""), ".ms2") |> UniMZ.mapvalue(UniMZ.dict_by_id)
    d[:n_scan] = sum(length, values(M))
    for t in d[:tasks]
        t[:label] = split(t[:id], '@')[begin]
        path = joinpath(ROOT, "out", d[:id], t[:id], string(t[:run]))
        t[:n_spec] = read_n_spec(path, d[:engine])
        println("$(path)\t=> $(t[:n_spec] / d[:n_scan])")
        t[:df] = read_psm(path, d[:engine])
        t[:z] = [sum(f.(t[:df].z)) for (_, f) in zs]
        t[:m] = [sum(f.(t[:df].mh .- UniMZ.mₚ)) for (_, f) in ms]
        tmp = DataFrames.combine(DataFrames.groupby(t[:df], [:file, :scan]), DataFrames.nrow)
        tmp = DataFrames.combine(DataFrames.groupby(tmp, [:nrow]), DataFrames.nrow => :nnrow)
        t[:n] = [sum(tmp[f.(tmp.nrow), :nnrow]) for (_, f) in ns]
        t[:n_id_spec] = size(t[:df], 1)
        t[:df].is_center = check_center(t[:df], M)
        t[:center] = sum(t[:df].is_center)
        t[:others] = sum(.!t[:df].is_center)
        t[:df].is_inside = check_inside(t[:df], M)
        t[:inside] = sum(t[:df].is_inside)
        t[:outside] = sum(.!t[:df].is_inside)
    end
end

for d in [D[:ZH2], D[:ZH8], D[:DD]]
    println(d[:id])
    println("Charge\t\t", join([z[1] for z in zs], "\t\t"))
    for t in d[:tasks]
        println(t[:label], "\t" ^ (2 - (length(t[:label]) ÷ 8)), join([@sprintf("& %d (%.2f\\%%)", z, z / sum(t[:z]) * 100) for z in t[:z]], "\t"), " \\\\")
    end
end

for d in [D[:ZH2], D[:ZH8], D[:DD]]
    println(d[:id])
    println("Mass (Da)\t", join([m[1] for m in ms], "\t"))
    for t in d[:tasks]
        println(t[:label], "\t" ^ (2 - (length(t[:label]) ÷ 8)), join([@sprintf("& %d (%.2f\\%%)", m, m / sum(t[:m]) * 100) for m in t[:m]], "\t"), " \\\\")
    end
end

for d in [D[:ZH2], D[:ZH8], D[:DD]]
    println(d[:id])
    println("#PSM per MS2\t", join([n[1] for n in ns], "\t\t"))
    for t in d[:tasks]
        println(t[:label], "\t" ^ (2 - (length(t[:label]) ÷ 8)), join([@sprintf("& %d (%.2f\\%%)", n, n / sum(d[:n_scan]) * 100) for n in t[:n]], "\t"), " \\\\")
    end
end

println("Center Ion\t", join([D[:ZH2][:id], D[:ZH8][:id], D[:DD][:id]], "\t\t\t"))
println("", "\t\tCenter\t\tOthers"^3)

for (i, t_) in enumerate(D[:ZH2][:tasks])
    print(t_[:label], "\t" ^ (1 - (length(t_[:label]) ÷ 8)))
    for d in [D[:ZH2], D[:ZH8], D[:DD]]
        t = d[:tasks][i]
        if t[:label] != t_[:label]
            error("ERROR")
        end
        print("\t", join([@sprintf("& %d (%.2f\\%%)", n, n / t[:n_id_spec] * 100) for n in [t[:center], t[:others]]], "\t"))
    end
    println(" \\\\")
end

println("Inside Ion\t", join([D[:ZH2][:id], D[:ZH8][:id], D[:DD][:id]], "\t\t\t"))
println("", "\t\tInside\t\tOutside"^3)

for (i, t_) in enumerate(D[:ZH2][:tasks])
    print(t_[:label], "\t" ^ (1 - (length(t_[:label]) ÷ 8)))
    for d in [D[:ZH2], D[:ZH8], D[:DD]]
        t = d[:tasks][i]
        if t[:label] != t_[:label]
            error("ERROR")
        end
        print("\t", join([@sprintf("& %d (%.2f\\%%)", n, n / t[:n_id_spec] * 100) for n in [t[:inside], t[:outside]]], "\t"))
    end
    println(" \\\\")
end
