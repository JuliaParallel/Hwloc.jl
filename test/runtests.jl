using Hwloc
using Test
import CpuId

version = Hwloc.get_api_version()
@test isa(version, VersionNumber)

# Topology (complete information)
topology = Hwloc.topology_load()
println("Topology:")
print(topology)
@test isa(topology, Hwloc.Object)

# Counts for various object types (e.g. cores)
counts = Hwloc.histmap(topology)
println("Histogram map:")
println(counts)
@test counts[:Core] > 0
@test counts[:PU] > 0
@test num_physical_cores() == counts[:Core]
@test cachesize() == CpuId.cachesize()

# Hierarchical summary of topology
hinfo = Hwloc.getinfo(topology)
println("Info:")
println(hinfo)
@test hinfo[1][1] ∈ (:System, :Machine)
@test hinfo[1][2] == 1
@test hinfo[end][1] == :PU
@test hinfo[end][2] > 0
