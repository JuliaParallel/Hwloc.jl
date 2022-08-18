using Hwloc
using Test
import CpuId

# trying to debug https://github.com/m-j-w/CpuId.jl/issues/55
display(CpuId.cpuinfo())
include(joinpath(dirname(pathof(CpuId)), "..", "test", "mock.jl"))
dump_cpuid_table()

@testset "Hwloc.jl" begin
    @testset "Version" begin
        version = Hwloc.get_api_version()
        @test isa(version, VersionNumber)
        @test version >= v"2.0"
    end

    @testset "Topology" begin
        println("Topology:")
        topology()
        topo = gettopology()
        println(topo)
        @test isa(topo, Hwloc.Object)
        @test hwloc_typeof(topo) ∈ (:Machine, :System)
        @test hwloc_isa(topo, :Machine) || hwloc_isa(topology, :System)
    end

    @testset "Topology (compact info)" begin
        println("Info:")
        topology_info()
        counts = getinfo(list_all=true)
        @test typeof(counts) == Dict{Symbol,Int}
        @test length(counts) == length(Hwloc.obj_types)
        println(counts)
        @test counts[:Machine] == 1 || counts[:System] == 1
        @test counts[:Core] > 0
        @test counts[:PU] > 0
        @test num_physical_cores() == counts[:Core]
        @test num_virtual_cores() == counts[:PU]
        @test num_packages() == counts[:Package]
        @test num_numa_nodes() == counts[:NUMANode]
        counts = getinfo(list_all=false)
        @test typeof(counts) == Dict{Symbol,Int}
        @test all(>(0), values(counts))
    end

    @testset "Cache (line) sizes" begin
        allequal(xs) = all(x == first(xs) for x in xs)
        l1, l2, l3 = CpuId.cachesize()
        counts = getinfo()

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
        @test cachesize(:L1) == first(l1s)
        @test cachesize(:L2) == first(l2s)
        @test cachesize(:L3) == first(l3s)

        if allequal(vcat(l1ls, l2ls, l3ls))
            cls = CpuId.cachelinesize()
            @test cachelinesize() == (L1=cls, L2=cls, L3=cls)
        end
        @test cachelinesize() == (L1=first(l1ls), L2=first(l2ls), L3=first(l3ls))
        @test cachelinesize(:L1) == first(l1ls)
        @test cachelinesize(:L2) == first(l2ls)
        @test cachelinesize(:L3) == first(l3ls)
    end

    @testset "Collecting objects" begin
        counts = getinfo()
        @test typeof(collectobjects(:L1Cache, gettopology())) == Vector{Hwloc.Object}
        @test typeof(collectobjects(:L1Cache)) == Vector{Hwloc.Object}
        @test length(collectobjects(:L1Cache)) == counts[:L1Cache]
        @test hwloc_typeof(first(collectobjects(:L1Cache))) == :L1Cache

        # collecting memory objects
        if counts[:NUMANode] > 0 # just in case the system doesn't have a NUMA node element
            @test length(collectobjects(:NUMANode)) == counts[:NUMANode]
            @test first(collectobjects(:NUMANode)).type_ == :NUMANode
            @test first(collectobjects(:NUMANode)).mem > 0
        end
    end
end
