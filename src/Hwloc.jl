module Hwloc
using Hwloc_jll

import Base: show, IteratorSize, IteratorEltype, isempty, eltype, iterate

include("wrappers.jl")
include("highlevel_api.jl")

export topology, topology_load, topology_info, print_topology, getinfo, histmap
export num_physical_cores, num_virtual_cores, num_packages, num_numa_nodes
export cachesize, cachelinesize
export get_api_version, hwloc_typeof, hwloc_isa, attributes, children, collectobjects

end
