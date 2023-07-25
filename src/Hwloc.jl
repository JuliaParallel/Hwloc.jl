module Hwloc
using Hwloc_jll
using Statistics

import Base: show, IteratorSize, IteratorEltype, isempty, eltype, iterate

include("libhwloc.jl")
include("libhwloc_extensions.jl")
include("lowlevel_api.jl")
include("highlevel_api.jl")
include("tree.jl")

export topology, gettopology, topology_info, getinfo, print_topology, topology_graphical
export num_physical_cores, num_virtual_cores, num_packages, num_numa_nodes
export cachesize, cachelinesize
export hwloc_typeof, hwloc_isa, collectobjects
export HwlocTreeNode

const machine_topology = Ref{Object}()

end
