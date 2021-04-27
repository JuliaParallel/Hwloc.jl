# Portable Hardware Locality (Hwloc)

[![Build Status](https://github.com/JuliaParallel/Hwloc.jl/workflows/CI/badge.svg)](https://github.com/JuliaParallel/Hwloc.jl/actions)
[![Coverage](https://codecov.io/gh/JuliaParallel/Hwloc.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaParallel/Hwloc.jl)

This Julia package wraps the [hwloc library](http://www.open-mpi.org/projects/hwloc/).

The Portable Hardware Locality (hwloc) software package provides a
portable abstraction (across OS, versions, architectures, ...) of the
hierarchical topology of modern architectures, including NUMA memory
nodes, sockets, shared caches, cores and simultaneous multithreading.
It also gathers various system attributes such as cache and memory
information as well as the locality of I/O devices such as network
interfaces, InfiniBand HCAs or GPUs. It primarily aims at helping
applications with gathering information about modern computing
hardware so as to exploit it accordingly and efficiently.



# Usage

The Julia module Hwloc provides a high-level wrapper of the hwloc
library; that is, hwloc's data structure are translated into Julia
types that contain the same information, but are modified to look
"natural" in Julia. Low-level administrative tasks are hidden.

The most important function is `Hwloc.topology()`, which examines
the current node's hardware topology (memories, caches, cores, etc.),
and displays a tree structure describing this topology. This
roughly corresponds to the output of the `lstopo` program. On my laptop this gives the following output:

```julia
julia> import Hwloc

julia> Hwloc.topology();
Machine (16.0 GB)
    Package L#0 P#0 (16.0 GB)
        NUMANode (16.0 GB)
        L3 (12.0 MB)
            L2 (256.0 KB)
                L1 (32.0 KB)
                    Core L#0 P#0 
                        PU L#0 P#0 
                        PU L#1 P#1 
            L2 (256.0 KB)
                L1 (32.0 KB)
                    Core L#1 P#1 
                        PU L#2 P#2 
                        PU L#3 P#3 
            L2 (256.0 KB)
                L1 (32.0 KB)
                    Core L#2 P#2 
                        PU L#4 P#4 
                        PU L#5 P#5 
            L2 (256.0 KB)
                L1 (32.0 KB)
                    Core L#3 P#3 
                        PU L#6 P#6 
                        PU L#7 P#7 
            L2 (256.0 KB)
                L1 (32.0 KB)
                    Core L#4 P#4 
                        PU L#8 P#8 
                        PU L#9 P#9 
            L2 (256.0 KB)
                L1 (32.0 KB)
                    Core L#5 P#5 
                        PU L#10 P#10 
                        PU L#11 P#11 
```

Often, one is only interested in a summary of this topology.
The function `Hwloc.topology_info()` provides this summary, which is loosely similar to the output of the `hwloc-info` command-line application.

```julia
julia> Hwloc.topology_info()
Machine: 1 (16.0 GB)
 Package: 1 (16.0 GB)
  NUMANode: 1 (16.0 GB)
   L3Cache: 1 (12.0 MB)
    L2Cache: 6 (256.0 KB)
     L1Cache: 6 (32.0 KB)
      Core: 6
       PU: 12
```

## Obtaining particular information:

### Number of cores, NUMA nodes, and sockets

`Hwloc` exports a few convenience functions for obtaining the number of physical and virtual cores (i.e. processing units), NUMA nodes, and sockets / packages:

```julia
julia> Hwloc.num_physical_cores()
6

julia> Hwloc.num_virtual_cores()
12

julia> Hwloc.num_numa_nodes()
1

julia> Hwloc.num_packages()
1
```

One may also use `Hwloc.getinfo()` to programmatically access some of the output of `Hwloc.topology_info()`:

```julia
julia> Hwloc.getinfo()
Dict{Symbol,Int64} with 8 entries:
  :L2Cache  => 6
  :NUMANode => 1
  :Core     => 6
  :Package  => 1
  :L1Cache  => 6
  :Machine  => 1
  :PU       => 12
  :L3Cache  => 1
```


### Cache properties

Assuming that multiple caches of the same level (e.g. L1) have identical properties, one can use the convenience functions `cachesize()` and `cachelinesize()` to obtain the relevant sizes in Bytes:

```julia
julia> Hwloc.cachesize()
(L1 = 32768, L2 = 262144, L3 = 12582912)

julia> Hwloc.cachelinesize()
(L1 = 64, L2 = 64, L3 = 64)
```

Otherwise, there are the following more specific functions available:
```julia
julia> @show Hwloc.l1cache_sizes();
       @show Hwloc.l2cache_sizes();
       @show Hwloc.l3cache_sizes();
Hwloc.l1cache_sizes() = [32768, 32768, 32768, 32768, 32768, 32768]
Hwloc.l2cache_sizes() = [262144, 262144, 262144, 262144, 262144, 262144]
Hwloc.l3cache_sizes() = [12582912]
````

### Manual access

```julia
julia> topo = Hwloc.topology_load()
Hwloc.Object: Machine

julia> fieldnames(typeof(topo))
(:type_, :os_index, :name, :attr, :mem, :depth, :logical_index, :children, :memory_children)

julia> Hwloc.children(topo)
1-element Array{Hwloc.Object,1}:
 Hwloc.Object: Package

julia> Hwloc.children(topo.children[1])
1-element Array{Hwloc.Object,1}:
 Hwloc.Object: L3Cache

julia> l2cache = Hwloc.children(topo.children[1].children[1])[1];

julia> Hwloc.attributes(l2cache)
Cache{size=262144,depth=2,linesize=64,associativity=4,type=Unified}

julia> l2cache |> Hwloc.print_topology
            L2 (256.0 KB)
                L1 (32.0 KB)
                    Core L#0 P#0 
                        PU L#0 P#0 
                        PU L#1 P#1
```

Topology elements of type `Hwloc.Object` also are Julia iterators. One can thus readily traverse the corresponding part of the topology tree:

```julia
julia> for obj in l2cache
           @show Hwloc.hwloc_typeof(obj)
       end
Hwloc.hwloc_typeof(obj) = :L2Cache
Hwloc.hwloc_typeof(obj) = :L1Cache
Hwloc.hwloc_typeof(obj) = :Core
Hwloc.hwloc_typeof(obj) = :PU
Hwloc.hwloc_typeof(obj) = :PU

julia> collect(subobj for subobj in l2cache)
5-element Array{Hwloc.Object,1}:
 Hwloc.Object: L2Cache
 Hwloc.Object: L1Cache
 Hwloc.Object: Core
 Hwloc.Object: PU
 Hwloc.Object: PU

julia> count(Hwloc.hwloc_isa(:PU), l2cache)
2

julia> collect(Iterators.filter(Hwloc.hwloc_isa(:PU), l2cache))
2-element Array{Hwloc.Object,1}:
 Hwloc.Object: PU
 Hwloc.Object: PU
```