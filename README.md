# Portable Hardware Locality (Hwloc)

[![Build Status](https://travis-ci.org/JuliaParallel/Hwloc.jl.svg?branch=master)](https://travis-ci.org/JuliaParallel/Hwloc.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/5gdday025kd4ni48?svg=true)](https://ci.appveyor.com/project/eschnett/hwloc-jl)
[![Coverage Status](https://coveralls.io/repos/JuliaParallel/Hwloc.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/JuliaParallel/Hwloc.jl?branch=master)

This Julia package wraps the hwloc library.

The Portable Hardware Locality (hwloc) software package provides a
portable abstraction (across OS, versions, architectures, ...) of the
hierarchical topology of modern architectures, including NUMA memory
nodes, sockets, shared caches, cores and simultaneous multithreading.
It also gathers various system attributes such as cache and memory
information as well as the locality of I/O devices such as network
interfaces, InfiniBand HCAs or GPUs. It primarily aims at helping
applications with gathering information about modern computing
hardware so as to exploit it accordingly and efficiently.

http://www.open-mpi.org/projects/hwloc/

# Usage

The Julia module Hwloc provides a high-level wrapper of the hwloc
library; that is, hwloc's data structure are translated into Julia
types that contain the same information, but are modified to look
"natural" in Julia. Low-level administrative tasks are hidden.

The most important function is `Hwloc.topology_load`, which examines
the current node's hardware topology (memories, caches, cores, etc.),
and returns a tree structure describing this topology. This
corresponds to the output of the `lstopo` program.

```
import Hwloc
topology = Hwloc.topology_load()
println("Machine topology:")
print(topology)
```

This outputs the full information, such as:
```
D0: L0 P0 Machine  
    D1: L0 P0 Node  
        D2: L0 P0 Cache  Cache{size=8388608,depth=3,linesize=64,associativity=0,type=Unified}
            D3: L0 P0 Cache  Cache{size=262144,depth=2,linesize=64,associativity=8,type=Unified}
                D4: L0 P0 Cache  Cache{size=32768,depth=1,linesize=64,associativity=0,type=Data}
                    D5: L0 P0 Core  
                        D6: L0 P0 PU  
                        D6: L1 P1 PU  
            D3: L1 P1 Cache  Cache{size=262144,depth=2,linesize=64,associativity=8,type=Unified}
                D4: L1 P1 Cache  Cache{size=32768,depth=1,linesize=64,associativity=0,type=Data}
                    D5: L1 P1 Core  
                        D6: L2 P2 PU  
                        D6: L3 P3 PU  
            D3: L2 P2 Cache  Cache{size=262144,depth=2,linesize=64,associativity=8,type=Unified}
                D4: L2 P2 Cache  Cache{size=32768,depth=1,linesize=64,associativity=0,type=Data}
                    D5: L2 P2 Core  
                        D6: L4 P4 PU  
                        D6: L5 P5 PU  
            D3: L3 P3 Cache  Cache{size=262144,depth=2,linesize=64,associativity=8,type=Unified}
                D4: L3 P3 Cache  Cache{size=32768,depth=1,linesize=64,associativity=0,type=Data}
                    D5: L3 P3 Core  
                        D6: L6 P6 PU  
                        D6: L7 P7 PU  
```

Often, one only wants an overview of the topology, omitting details.
The function `Hwloc.getinfo` does this, similar to the output of the
`hwloc-info` program.

```
import Hwloc
topology = Hwloc.topology_load()
summary = Hwloc.getinfo(topology)
println("Machine overview:")
for obj in summary
    obj_type = obj[1]
    count = obj[2]
    println("$count $obj_type")
end
```

This may output:
```
1 Machine
1 Node
1 Cache
4 Cache
4 Cache
4 Core
8 PU
```

## Obtaining particular information:

The number of cores and virtual cores (PUs):

```
import Hwloc
topology = Hwloc.topology_load()
counts = Hwloc.histmap(topology)
ncores = counts[:Core]
npus = counts[:PU]
println("This machine has $ncores cores and $npus PUs (processing units)")
```

This may print:
```
This machine has 4 cores and 8 PUs (processing units)
```

The L1 cache properties:

```
import Hwloc
topology = Hwloc.topology_load()
l1cache = first(filter(t->t.type_==:Cache && t.attr.depth==1, topology)).attr
println("L1 cache information: $l1cache")
```

This may print:
```
L1 cache information: Cache{size=32768,depth=1,linesize=64,associativity=0,type=Data}
```
