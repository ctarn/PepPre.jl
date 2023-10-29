module PepPre

include("PepPreIsolated.jl")
include("PepPreView.jl")

main_PepPreIsolated()::Cint = PepPreIsolated.julia_main()
main_PepPreView()::Cint = PepPreView.julia_main()

end
