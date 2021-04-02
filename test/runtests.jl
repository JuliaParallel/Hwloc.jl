using Hwloc
using Test
using CpuId

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
@test num_packages() == counts[:Package]

# Cache sizes
allequal(xs) = all(x == first(xs) for x in xs)
l1, l2, l3 = CpuId.cachesize()

l1s = l1cache_sizes()
@test length(l1s) == counts[:L1Cache]
if allequal(l1s) # running on a machine with equal caches
    @test first(l1s) == l1
end
l2s = l2cache_sizes()
@test length(l2s) == counts[:L2Cache]
if allequal(l2s) # running on a machine with equal caches
    @test first(l2s) == l2
end
l3s = l3cache_sizes()
@test length(l3s) == counts[:L3Cache]
if allequal(l3s) # running on a machine with equal caches
    @test first(l3s) == l3
end

@test typeof(collectobjects(topology, :L1Cache)) == Vector{Hwloc.Object}
@test length(collectobjects(topology, :L1Cache)) == counts[:L1Cache]
@test first(collectobjects(topology, :L1Cache)).type_ == :L1Cache

# Hierarchical summary of topology
hinfo = Hwloc.getinfo(topology)
println("Info:")
println(hinfo)
@test hinfo[1][1] ∈ (:System, :Machine)
@test hinfo[1][2] == 1
@test hinfo[end][1] == :PU
@test hinfo[end][2] > 0
