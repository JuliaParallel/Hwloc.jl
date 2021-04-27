module Hwloc
using Hwloc_jll

import Base: show
import Base: IteratorSize, IteratorEltype, isempty, eltype, iterate

include("wrappers.jl")
include("highlevel_api.jl")

export get_api_version, getinfo, histmap, num_physical_cores
export collectobjects, attributes, num_packages, num_numa_nodes, cachesize, cachelinesize
export topology, load_topology, print_topology, print_summary

end
