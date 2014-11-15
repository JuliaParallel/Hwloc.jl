import hwloc
using Base.Test

version = hwloc.get_api_version()
@test isa(version, VersionNumber)

topology = hwloc.topology_load()
@test isa(topology, hwloc.Object)

types, counts = hwloc.hist(topology)
# Dict{Symbol,Int}(zip(types, counts))
@test counts[findfirst(types, :PU)] > 0

info = hwloc.info(topology)
@test info[1][1] ∈ (:System, :Machine)
@test info[1][2] == 1
@test info[end][1] == :PU
@test info[end][2] > 0
@test info[findfirst(hwloc.obj_types, :PU)][1] == :PU
@test info[findfirst(hwloc.obj_types, :PU)][2] > 0
