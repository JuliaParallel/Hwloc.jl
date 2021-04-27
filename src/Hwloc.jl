module Hwloc
using Hwloc_jll

import Base: show, IteratorSize, IteratorEltype, isempty, eltype, iterate

include("wrappers.jl")
include("highlevel_api.jl")

export get_api_version, getinfo, histmap, num_physical_cores, num_virtual_cores
export collectobjects, attributes, children, num_packages, num_numa_nodes, cachesize, cachelinesize
export topology, topology_load, print_topology, print_summary, hwloc_typeof, hwloc_isa

end
