module PepPre

include("PepPreIsolated.jl")
include("PepPreGlobal.jl")
include("PepPreAlign.jl")
include("PepPreView.jl")

main_PepPreIsolated()::Cint = PepPreIsolated.julia_main()
main_PepPreGlobal()::Cint = PepPreGlobal.julia_main()
main_PepPreAlign()::Cint = PepPreAlign.julia_main()
main_PepPreView()::Cint = PepPreView.julia_main()

end
