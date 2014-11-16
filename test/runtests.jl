import hwloc
using Base.Test

version = hwloc.get_api_version()
@test isa(version, VersionNumber)

topology = hwloc.topology_load()
println("Topology:")
print(topology)
@test isa(topology, hwloc.Object)

counts = hwloc.hist(topology)
println("Histogram map:")
println(counts)
@test counts[:PU] > 0

types, counts = hwloc.hist(topology)
println("Histogram:")
println(zip(types, counts))
@test counts[findfirst(types, :PU)] > 0

info = hwloc.info(topology)
println("Info:")
println(info)
@test info[1][1] ∈ (:System, :Machine)
@test info[1][2] == 1
@test info[end][1] == :PU
@test info[end][2] > 0
