using Hwloc
using Base.Test

version = Hwloc.get_api_version()
@test isa(version, VersionNumber)

# Topology (complete information)
topology = Hwloc.topology_load()
println("Topology:")
print(topology)
@test isa(topology, Hwloc.Object)

# Counts for various object types (e.g. cores)
counts = Hwloc.hist_map(topology)
println("Histogram map:")
println(counts)
@test counts[:Core] > 0
@test counts[:PU] > 0

# Hierarchical summary of topology
info = Hwloc.info(topology)
println("Info:")
println(info)
@test info[1][1] ∈ (:System, :Machine)
@test info[1][2] == 1
@test info[end][1] == :PU
@test info[end][2] > 0
