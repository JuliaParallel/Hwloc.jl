# Portable Hardware Locality (Hwloc)

[![Build Status](https://github.com/JuliaParallel/Hwloc.jl/workflows/CI/badge.svg)](https://github.com/JuliaParallel/Hwloc.jl/actions)
[![Coverage](https://codecov.io/gh/JuliaParallel/Hwloc.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaParallel/Hwloc.jl)

Hwloc.jl is a high-level wrapper of the
[hwloc library](http://www.open-mpi.org/projects/hwloc/). It examines the current machine's
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

Machine (31.05 GB)
    Package L#0 P#0 (31.05 GB)
        NUMANode (31.05 GB)
        L3 (12.0 MB)
            L2 (1.25 MB)
             + L1 (48.0 kB)
             + Core L#0 P#0 
                PU L#0 P#0 
                PU L#1 P#4 
            L2 (1.25 MB)
             + L1 (48.0 kB)
             + Core L#1 P#1 
                PU L#2 P#1 
                PU L#3 P#5 
            L2 (1.25 MB)
             + L1 (48.0 kB)
             + Core L#2 P#2 
                PU L#4 P#2 
                PU L#5 P#6 
            L2 (1.25 MB)
             + L1 (48.0 kB)
             + Core L#3 P#3 
                PU L#6 P#3 
                PU L#7 P#7 
    HostBridge 
        PCI 00:02.0 (VGA)
            GPU "renderD128"
            GPU "card0"
        PCIBridge 
            PCI 01:00.0 (NVMExp)
                Block(Disk) "nvme0n1"
        PCIBridge 
            PCI 72:00.0 (Network)
                Net "wlp114s0"
        PCIBridge 
            PCI 73:00.0 (Other)
                Block "mmcblk0"

```

Often, one is only interested in a summary of this topology.
The function `topology_info()` provides such a compact description, which is loosely similar to the output of the `hwloc-info` command-line application.

```julia
julia> topology_info()
Machine: 1 (31.05 GB)
 Package: 1 (31.05 GB)
  NUMANode: 1 (31.05 GB)
   L3Cache: 1 (12.0 MB)
    L2Cache: 4 (1.25 MB)
     L1Cache: 4 (48.0 kB)
      Core: 4
       PU: 8
```

If you prefer a more verbose graphical visualization you may consider using `topology_graphical()`:

<img width="1806" alt="Screenshot 2022-09-27 at 12 06 57" src="https://user-images.githubusercontent.com/187980/192498088-712d7ff0-c8ac-4535-b386-c08d3d0eddb3.png">

(Note that as of now this may not produce colorful output on all systems.)


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
Dict{Symbol, Int64} with 8 entries:
  :L2Cache  => 4
  :NUMANode => 1
  :Core     => 4
  :Package  => 1
  :L1Cache  => 4
  :Machine  => 1
  :PU       => 8
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
L2 (256.0 kB) + L1 (32.0 kB) + Core L#0 P#0 
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

### Manual topology query and caching

On the first call of `gettopology()`, Hwloc.jl examines the current machine's
hardware topology and caches the result in `Hwloc.machine_topology`.

To query the system the system topology again -- i.e. not using the cached
`Hwloc.Object` representing the entire machine -- simply pass the `reload=true` (`false` by default) kwarg:

```julia
julia> topo = gettopology(;reload=true)
Hwloc.Object: Machine
```

### Do not include I/O devices in topology object

You may prefer not to include I/O devices in you Hwloc tree, then we recommend
passing the `get_io=false` (`true` by default) kwarg, in addition to `reload`
(cf. above):

```julia
julia> topo = gettopology(;reload=true, get_io=false)
Hwloc.Object: Machine

julia> topology(topo)
Machine (31.05 GB)
    Package L#0 P#0 (31.05 GB)
        NUMANode (31.05 GB)
        L3 (12.0 MB)
            L2 (1.25 MB) + L1 (48.0 kB) + Core L#0 P#0 
                PU L#0 P#0 
                PU L#1 P#4 
            L2 (1.25 MB) + L1 (48.0 kB) + Core L#1 P#1 
                PU L#2 P#1 
                PU L#3 P#5 
            L2 (1.25 MB) + L1 (48.0 kB) + Core L#2 P#2 
                PU L#4 P#2 
                PU L#5 P#6 
            L2 (1.25 MB) + L1 (48.0 kB) + Core L#3 P#3 
                PU L#6 P#3 
                PU L#7 P#7 
```
(note: to avoid caching by eccident, we recommend passing `reload=true` to
`gettopology`)

### Low-level API for accessing the underlying topology object.

**Warning:** As discussed earlier, `Hwloc.jl` makes heavy use of caching in the
high-level API. Using the low-level and high-level APIs together can result in
cached values being used by accident! We therefore recommend that the high-level
`gettopology` funcion is used, where caching is controlled via the `reload`
kwarg.

Under the hood, `gettopology` uses `Hwloc.topology_init` and
`Hwloc.topology_load` to directly `ccall` into `libhwloc`. `Hwloc.topology_init`
is reponsible for creating a low-level `LibHwloc.hwloc_topology` object.
`Hwloc.topology_load` wraps this a `Hwloc.Object` Julia object.

**Note:** `Hwloc.topology_load` is destructive to the `LibHwloc.hwloc_topology`
object:

```julia
julia> htopo = Hwloc.topology_init()
Ptr{Hwloc.LibHwloc.hwloc_topology} @0x000000000883cf60

julia> topo = Hwloc.topology_load(htopo)
Hwloc.Object: Machine

julia> topo = Hwloc.topology_load(htopo)
ERROR: AssertionError: ierr == 0
Stacktrace:
 [1] topology_load(htopo::Ptr{Hwloc.LibHwloc.hwloc_topology})
   @ Hwloc ~/.julia/dev/Hwloc/src/lowlevel_api.jl:347
 [2] top-level scope
   @ REPL[78]:1
```

This is because `LibHwloc.hwloc_topology` are not garbage-collected (a call to
`Hwloc.topology_init`, without a later call to `Hwloc.hwloc_topology_destroy`
will leak memory). This is why `Hwloc.topology_load` calls
`Hwloc.hwloc_topology_destroy` after creating the `Hwloc.Object` Julia object
(which is garbage collected!).


## Hwloc objects are `AbstractTrees`

If the [`AbstractTrees`](https://github.com/JuliaCollections/AbstractTrees.jl)
module is loaded, then passing an `Hwloc.Object` to `AbstractTrees.children`
will construct an `HwlocTreeNode`. Calling `children(gettopology())` will
return the Hwloc tree root:

```julia
julia> using AbstractTrees, Hwloc

julia> t = children(gettopology());

julia> print_tree(t; maxdepth=2)
Hwloc.Object: Machine
├─ Hwloc.Object: Package [L#0 P#0]
│  ├─ Hwloc.Object: L3Cache
│  │  ⋮
│  │  
│  └─ Hwloc.Object: NUMANode
└─ Hwloc.Object: Bridge [HostBridge]
   ├─ Hwloc.Object: PCI_Device [00:00.0 (HostBridge)]
   ├─ Hwloc.Object: PCI_Device [00:02.0 (VGA)]
   │  ⋮
   │  
   ├─ Hwloc.Object: PCI_Device [00:04.0 (SignalProcessing)]
   ├─ Hwloc.Object: Bridge [PCIBridge]
   │  ⋮
   │  
   ├─ Hwloc.Object: Bridge [PCIBridge]
   ├─ Hwloc.Object: Bridge [PCIBridge]
   ├─ Hwloc.Object: PCI_Device [00:0a.0 (SignalProcessing)]
   ├─ Hwloc.Object: PCI_Device [00:0d.0 (USB)]
   ├─ Hwloc.Object: PCI_Device [00:0d.2 (USB)]
   ├─ Hwloc.Object: PCI_Device [00:0d.3 (USB)]
   ├─ Hwloc.Object: PCI_Device [00:12.0 (Serial)]
   ├─ Hwloc.Object: PCI_Device [00:14.0 (USB)]
   ├─ Hwloc.Object: PCI_Device [00:14.2 (RAM)]
   ├─ Hwloc.Object: PCI_Device [00:15.0 (SerialBus)]
   │  ⋮
   │  
   ├─ Hwloc.Object: PCI_Device [00:15.1 (SerialBus)]
   │  ⋮
   │  
   ├─ Hwloc.Object: PCI_Device [00:16.0 (Communication)]
   ├─ Hwloc.Object: PCI_Device [00:19.0 (SerialBus)]
   │  ⋮
   │  
   ├─ Hwloc.Object: PCI_Device [00:19.1 (SerialBus)]
   │  ⋮
   │  
   ├─ Hwloc.Object: Bridge [PCIBridge]
   │  ⋮
   │  
   ├─ Hwloc.Object: Bridge [PCIBridge]
   │  ⋮
   │  
   ├─ Hwloc.Object: PCI_Device [00:1f.0 (ISABridge)]
   ├─ Hwloc.Object: PCI_Device [00:1f.3 (MultimediaAudio)]
   ├─ Hwloc.Object: PCI_Device [00:1f.4 (SMBus)]
   └─ Hwloc.Object: PCI_Device [00:1f.5 (SerialBus)]

```

For examples of using the AbstracTree interface to search the Hwloc tree, see:
[NetworkInterfaceControllers.jl](https://github.com/JuliaParallel/NetworkInterfaceControllers.jl)