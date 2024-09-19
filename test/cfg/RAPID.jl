path_data = ARGS[1]
path_out = ARGS[2]
mkpath(path_out)

files = filter(f -> startswith(f, basename(path_data)) && endswith(f, ".mzXML"), readdir(dirname(path_data)))
println(dirname(path_data))
foreach(println, files)

cfg = """
#Allowed only mzXML after peak picking
File::DataType				MZXML
<File::DataList>
$(join(map(f -> "./$(joinpath(path_data, f))", files), "\n"))

PeakPicking::SNRThreshold		0.0
PeakPicking::BackgroundRatio		0.1
PeakPicking::FitType			QUADRATIC

DeconvPep::MaxCharge			6
DeconvPep::ThScore			0.0
DeconvPep::OutputFormat			CSV
DeconvPep::ResultOrder			ABUNDANCE
DeconvPep::Target			MS
DeconvPep::Truncated			YES

AdvDeconv::MaxAbundancePeak		3
AdvDeconv::ScanNoModifier		0
AdvDeconv::MaxMissPeak			3
AdvDeconv::MassErr			1.0E-05
"""
open(joinpath(path_out, "RAPID.txt"), write=true) do io
    write(io, cfg)
end
