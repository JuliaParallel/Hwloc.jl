module Hwloc
using Hwloc_jll

import Base: show, IteratorSize, IteratorEltype, isempty, eltype, iterate

include("libhwloc.jl")
include("libhwloc_extensions.jl")
include("lowlevel_api.jl")
include("highlevel_api.jl")

export topology, gettopology, topology_info, getinfo, print_topology, topology_graphical
export num_physical_cores, num_virtual_cores, num_packages, num_numa_nodes, num_cpukinds, num_virtual_cores_cpukinds
export cachesize, cachelinesize
export hwloc_typeof, hwloc_isa, collectobjects

const machine_topology = Ref{Object}()

# Compatibility with older Julia versions + module extensions:
if !isdefined(Base, :get_extension)
    include(joinpath("..", "ext", "HwlocTrees.jl"))
end

end
