import PackageCompiler
import Pkg
import TOML

rm("Manifest.toml", force=true)

cfg = TOML.parsefile("Project.toml")

dir = "tmp/$(Sys.ARCH).$(Sys.iswindows() ? "Windows" : Sys.KERNEL)/$(cfg["name"])"

exes = ["PepPre", "PepPreView"]
deps = ["../MesMS.jl", "../MesUtil.jl"]
Pkg.develop([Pkg.PackageSpec(path=dep) for dep in deps])
Pkg.resolve()
PackageCompiler.create_app(".", dir;
    executables=[exe => "main_$(exe)" for exe in exes],
    force=true, include_lazy_artifacts=true, include_transitive_dependencies=true,
)

open(joinpath(dir, "VERSION"); write=true) do io
    write(io, cfg["version"])
end
