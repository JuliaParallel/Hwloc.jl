using Hwloc
using Test
import CpuId

version = Hwloc.get_api_version()
@test isa(version, VersionNumber)
@test version >= v"2.0"

# Topology (complete information)
topology = Hwloc.topology_load()
@test isa(topology, Hwloc.Object)
@test hwloc_typeof(topology) ∈ (:Machine, :System)
@test hwloc_isa(topology, :Machine) || hwloc_isa(topology, :System)
println("Topology:")
topology = Hwloc.topology()
@test isa(topology, Hwloc.Object)

# Counts for various object types (e.g. cores)
counts = Hwloc.getinfo(topology; list_all=true)
println("Histogram map:")
println(counts)
@test counts[:Core] > 0
@test counts[:PU] > 0
@test num_physical_cores() == counts[:Core]
@test num_packages() == counts[:Package]
@test num_numa_nodes() == counts[:NUMANode]

# Cache sizes
allequal(xs) = all(x == first(xs) for x in xs)
l1, l2, l3 = CpuId.cachesize()

l1s = Hwloc.l1cache_sizes()
l1ls = Hwloc.l1cache_linesizes()
@test length(l1s) == counts[:L1Cache]
@test length(l1ls) == counts[:L1Cache]
if allequal(l1s) # running on a machine with equal caches
    @test first(l1s) == l1
end
l2s = Hwloc.l2cache_sizes()
l2ls = Hwloc.l2cache_linesizes()
@test length(l2s) == counts[:L2Cache]
@test length(l2ls) == counts[:L2Cache]
if allequal(l2s) # running on a machine with equal caches
    @test first(l2s) == l2
end
l3s = Hwloc.l3cache_sizes()
l3ls = Hwloc.l3cache_linesizes()
@test length(l3s) == counts[:L3Cache]
@test length(l3ls) == counts[:L3Cache]
if allequal(l3s) # running on a machine with equal caches
    @test first(l3s) == l3
end

@test cachesize() == (L1=first(l1s), L2=first(l2s), L3=first(l3s))

if allequal(vcat(l1ls, l2ls, l3ls))
    cls = CpuId.cachelinesize()
    @test cachelinesize() == (L1=cls, L2=cls, L3=cls)
end
@test cachelinesize() == (L1=first(l1ls), L2=first(l2ls), L3=first(l3ls))

# collecting normal objects
@test typeof(collectobjects(topology, :L1Cache)) == Vector{Hwloc.Object}
@test length(collectobjects(topology, :L1Cache)) == counts[:L1Cache]
@test first(collectobjects(topology, :L1Cache)).type_ == :L1Cache

# collecting memory objects
if counts[:NUMANode] > 0 # just in case the system doesn't have a NUMA node element
    @test length(collectobjects(topology, :NUMANode)) == counts[:NUMANode]
    @test first(collectobjects(topology, :NUMANode)).type_ == :NUMANode
    @test first(collectobjects(topology, :NUMANode)).mem > 0
end

# Hierarchical summary of topology
println("Info:")
Hwloc.topology_info()
hinfo = Hwloc.getinfo(topology)
@test typeof(hinfo) == Dict{Symbol, Int}
@test haskey(hinfo, :Machine)
@test hinfo[:Machine] == 1
@test hinfo[:PU] > 0
