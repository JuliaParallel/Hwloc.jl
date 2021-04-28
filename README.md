# Portable Hardware Locality (Hwloc)

[![Build Status](https://github.com/JuliaParallel/Hwloc.jl/workflows/CI/badge.svg)](https://github.com/JuliaParallel/Hwloc.jl/actions)
[![Coverage](https://codecov.io/gh/JuliaParallel/Hwloc.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaParallel/Hwloc.jl)

Hwloc.jl is a high-level wrapper of the
[hwloc library](http://www.open-mpi.org/projects/hwloc/).

Upon `import` or `using`, Hwloc.jl examines the current machine's
hardware topology (memories, caches, cores, etc.) and provides
Julia functions to visualize and access this information conveniently.

Taken from the [hwloc website](http://www.open-mpi.org/projects/hwloc/):
> The Portable Hardware Locality (hwloc) software package provides a portable abstraction (across OS, versions, architectures, ...) of the hierarchical topology of modern architectures, including NUMA memory nodes, sockets, shared caches, cores and simultaneous multithreading. It also gathers various system attributes such as cache and memory information as well as the locality of I/O devices such as network interfaces, InfiniBand HCAs or GPUs.
> 
> hwloc primarily aims at helping applications with gathering information about increasingly complex parallel computing platforms so as to exploit them accordingly and efficiently.

# Usage

Perhaps the most important function is `Hwloc.topology()` which
displays a tree structure describing the system topology. This
roughly corresponds to the output of the `lstopo` program (non-GUI version).
On my laptop this gives the following output:

```julia
julia> using Hwloc

julia> topology()
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
The function `topology_info()` provides such a compact description, which is loosely similar to the output of the `hwloc-info` command-line application.

```julia
julia> topology_info()
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

`Hwloc` exports a few convenience functions for obtaining particularly import information,
such as the number of physical and virtual cores (i.e. processing units), NUMA nodes, and sockets / packages:

```julia
julia> num_physical_cores()
6

julia> num_virtual_cores()
12

julia> num_numa_nodes()
1

julia> num_packages()
1
```

One may also use `getinfo()` to programmatically access some of the output of `topology_info()`:

```julia
julia> getinfo()
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
julia> cachesize()
(L1 = 32768, L2 = 262144, L3 = 12582912)

julia> cachelinesize()
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

To manually traverse and investigate the system topology tree, one may use `gettopology()` to
obtain the top-level `Hwloc.Object`.

**Note:** `gettopology()` directly returns the `Hwloc.Object` stored in `Hwloc.machine_topology` and should thus be taken as providing a "view" into the system topology. One should not modify the returned object!

```julia
julia> topo = gettopology()
Hwloc.Object: Machine

julia> fieldnames(typeof(topo))
(:type_, :os_index, :name, :attr, :mem, :depth, :logical_index, :children, :memory_children)

julia> Hwloc.children(topo)
1-element Array{Hwloc.Object,1}:
 Hwloc.Object: Package

julia> Hwloc.children(topo.children[1])
1-element Array{Hwloc.Object,1}:
 Hwloc.Object: L3Cache

julia> l2cache = Hwloc.children(topo.children[1].children[1])[1]
Hwloc.Object: L2Cache

julia> Hwloc.attributes(l2cache)
Cache{size=262144,depth=2,linesize=64,associativity=4,type=Unified}

julia> l2cache |> print_topology
            L2 (256.0 KB)
                L1 (32.0 KB)
                    Core L#0 P#0 
                        PU L#0 P#0 
                        PU L#1 P#1
```

Topology elements of type `Hwloc.Object` also are Julia iterators. One can thus readily traverse the corresponding part of the topology tree:

```julia
julia> for obj in l2cache
           @show hwloc_typeof(obj)
       end
hwloc_typeof(obj) = :L2Cache
hwloc_typeof(obj) = :L1Cache
hwloc_typeof(obj) = :Core
hwloc_typeof(obj) = :PU
hwloc_typeof(obj) = :PU

julia> collect(obj for obj in l2cache)
5-element Array{Hwloc.Object,1}:
 Hwloc.Object: L2Cache
 Hwloc.Object: L1Cache
 Hwloc.Object: Core
 Hwloc.Object: PU
 Hwloc.Object: PU

julia> count(hwloc_isa(:PU), l2cache)
2

julia> collectobjects(:PU, l2cache)
2-element Array{Hwloc.Object,1}:
 Hwloc.Object: PU
 Hwloc.Object: PU
```

### Manual topology query

Upon `import` or `using`, Hwloc.jl examines the current machine's
hardware topology and caches the result in `Hwloc.machine_topology`.
To manually query the system topology one may use `Hwloc.topology_load`
which directly `ccall`s into `libhwloc` and directly returns the
resulting `Hwloc.Object`.