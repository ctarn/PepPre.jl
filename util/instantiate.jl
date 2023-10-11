import Pkg

rm("Manifest.toml", force=true)
isempty(ARGS) || Pkg.develop([Pkg.PackageSpec(path=dep) for dep in ARGS])
Pkg.resolve()
