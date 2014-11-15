# Portable Hardware Locality (hwloc)

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

The Julia module hwloc provides a high-level wrapper of the hwloc
library; that is, hwloc's data structure are translated into Julia
types that contain the same information, but are modified to look
"natural" in Julia. Low-level administrative tasks are hidden.

The most important function is `hwloc.topology_load`, which examines
the current node's hardware topology (memories, caches, cores, etc.),
and returns a tree structure describing this topology. This
corresponds to the output of the `lstopo` program.

```
topology = hwloc.topology_load()
println("Machine topology:")
print(topology)
```

Often, one only wants an overview of the topology, omitting details.
The function `hwloc.info` does this, similar to the output of the
`hwloc-info` program.

```
topology = hwloc.topology_load()
summary = hwloc.summary(topology)
ncores = Dict(summary)[:Core]
npus = Dict(summary)[:PU]
println("This machine has $ncores cores and $npus PUs (processing units)")
```
