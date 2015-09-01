VERSION >= v"0.4.0-dev+6521" && __precompile__()

module Hwloc

import Base: isempty, start, done, next, length
import Base: show

if isfile(joinpath(dirname(dirname(@__FILE__)),"deps","deps.jl"))
    include("../deps/deps.jl")
else
    error("Hwloc not properly installed; please run Pkg.build(\"Hwloc\")")
end

export get_api_version, topology_load, info, hist_map



# Note: These must correspond to <hwloc.h>

typealias hwloc_bitmap_t Ptr{Void}
typealias hwloc_cpuset_t hwloc_bitmap_t
typealias hwloc_nodeset_t hwloc_bitmap_t

typealias hwloc_obj_type_t Cint
typealias hwloc_obj_cache_type_t Cint
typealias hwloc_obj_bridge_type_t Cint
typealias hwloc_obj_osdev_type_t Cint

# Note: The order of these declaration must correspond to then enums
# in <hwloc.h>
const obj_types = Symbol[:System, :Machine, :Node, :Socket, :Cache, :Core, :PU,
                         :Group, :Misc, :Bridge, :PCI_Device, :OS_Device,
                         :Error]
const cache_types = Symbol[:Unified, :Data, :Instruction]
# const bridge_types
const osdev_types = Symbol[:Block, :GPU, :Network, :Openfabrics, :DMA, :CoProc]



immutable hwloc_obj_memory_page_type_s
    size::Uint64
    count::Uint64
end

immutable hwloc_obj_memory_s
    total_memory::Uint64
    local_memory::Uint64
    page_types_len::Cuint
    page_types::Ptr{hwloc_obj_memory_page_type_s}
end

immutable hwloc_distances_s
    relative_depth::Cuint
    nbobjs::Cuint
    latency::Ptr{Cfloat}
    latency_max::Cfloat
    latency_base::Cfloat
end

immutable hwloc_obj_info_s
    name::Ptr{Cchar}
    value::Ptr{Cchar}
end

immutable hwloc_obj
    # physical information
    type_::hwloc_obj_type_t
    os_index::Cuint
    name::Ptr{Cchar}
    memory::hwloc_obj_memory_s
    attr::Ptr{Void}             # Ptr{hwloc_obj_attr_u}
    
    # global position
    depth::Cuint
    logical_index::Cuint
    os_level::Cint
    
    # cousins
    next_cousin::Ptr{hwloc_obj}
    prev_cousin::Ptr{hwloc_obj}
    
    # siblings
    parent::Ptr{hwloc_obj}
    sibling_rank::Cuint
    next_sibling::Ptr{hwloc_obj}
    prev_sibling::Ptr{hwloc_obj}
    
    # children
    arity::Cuint
    children::Ptr{Ptr{hwloc_obj}}
    first_child::Ptr{hwloc_obj}
    last_child::Ptr{hwloc_obj}
    
    # misc
    userdata::Ptr{Void}
    
    # cpusets and nodesets
    cpuset::hwloc_cpuset_t
    complete_cpuset::hwloc_cpuset_t
    online_cpuset::hwloc_cpuset_t
    allowed_cpuset::hwloc_cpuset_t
    nodeset::hwloc_nodeset_t
    complete_nodeset::hwloc_nodeset_t
    allowed_nodeset::hwloc_nodeset_t
    
    # distances
    distances::Ptr{Ptr{hwloc_distances_s}}
    distances_count::Cuint
    
    # infos
    infos::Ptr{hwloc_obj_info_s}
    infos_count::Cuint
    
    # symmetry
    symmetric_subtree::Cint
end
typealias hwloc_obj_t Ptr{hwloc_obj}

immutable hwloc_cache_attr_s
    size::Uint64
    depth::Cuint
    linesize::Cuint
    associativity::Cint
    type_::hwloc_obj_cache_type_t
end

immutable hwloc_group_attr_s
    depth::Cuint
end

immutable hwloc_pcidev_attr_s
    domain::Cushort
    bus::Cuchar
    dev::Cuchar
    func::Cuchar
    class_id::Cushort
    vendor_id::Cushort
    device_id::Cushort
    subvendor_id::Cushort
    subdevice_id::Cushort
    revision::Cuchar
    linkspeed::Cfloat
end

# hwloc_bridge_attr_s

immutable hwloc_osdev_attr_s
    type_::hwloc_obj_osdev_type_t
end



abstract Attribute

type NullAttr <: Attribute
end
show(io::IO, a::NullAttr) = print(io, "")

type CacheAttr <: Attribute
    size::Int
    depth::Int                  # cache level
    linesize::Int
    associativity::Int
    type_::Symbol
end
function show(io::IO, a::CacheAttr)
    print(io, "Cache{size=$(a.size),depth=$(a.depth),linesize=$(a.linesize),",
          "associativity=$(a.associativity),type=$(string(a.type_))}")
end

type GroupAttr <: Attribute
    depth::Int
end
function show(io::IO, a::GroupAttr)
    print(io, "Group{depth=$(a.depth)}")
end

type PCIDevAttr <: Attribute
    domain::Int
    bus::Int
    dev::Int
    func::Int
    class_id::Int
    vendor_id::Int
    device_id::Int
    subvendor_id::Int
    subdevice_id::Int
    revision::Int
    linkspeed::Float32
end
# TODO: expand this
show(io::IO, a::PCIDevAttr) = print(io, "PCIDev{...}")

# type BridgeAttr <: Attribute end

type OSDevAttr <: Attribute
    type_::Symbol
end
function show(io::IO, a::OSDevAttr)
    print(io, "OSDev{type=$(string(a.type_))}")
end



type Object
    type_::Symbol
    os_index::Int
    name::ASCIIString
    attr::Attribute
    
    depth::Int
    logical_index::Int
    os_level::Int
    
    children::Vector{Object}
    
    Object() = new(:Error, -1, "(nothing)", NullAttr(),
                   -1, -1, -1,
                   Object[])
end

isempty(::Object) = false
start(obj::Object) = [obj]
done(::Object, state::Vector{Object}) = isempty(state)
function next(::Object, state::Vector{Object})
    obj = shift!(state)
    prepend!(state, obj.children)
    return obj, state
end

length(obj::Object) = mapreduce(x->1, +, obj)

function show(io::IO, obj::Object)
    println(io, repeat(" ", 4*max(0,obj.depth)),
            "D$(obj.depth): L$(obj.logical_index) P$(obj.os_index) ",
            "$(string(obj.type_)) $(obj.name) $(obj.attr)")
    for child in obj.children
        show(io, child)
    end
end



function get_api_version()
    version = ccall((:hwloc_get_api_version, libhwloc), Cuint, ())
    patch = version % 256
    version = version ÷ 256
    minor = version % 256
    version = version ÷ 256
    major = version
    VersionNumber(major, minor, patch)
end



function topology_load()
    htopop = Array(Ptr{Void}, 1)
    ierr = ccall((:hwloc_topology_init, libhwloc), Cint, (Ptr{Void},), htopop)
    @assert ierr==0
    htopo = htopop[1]
    ierr = ccall((:hwloc_topology_load, libhwloc), Cint, (Ptr{Void},), htopo)
    @assert ierr==0
    
    nroots = Int(ccall((:hwloc_get_nbobjs_by_depth, libhwloc), Cuint,
                       (Ptr{Void}, Cuint), htopo, 0))
    @assert nroots == 1
    root = ccall((:hwloc_get_obj_by_depth, libhwloc), hwloc_obj_t,
                 (Ptr{Void}, Cuint, Cuint), htopo, 0, 0)
    topo = load(root)
    
    ccall((:hwloc_topology_destroy, libhwloc), Void, (Ptr{Void},), htopo)
    
    return topo
end

# Load topology for an object and all its children
function load(hobj::hwloc_obj_t)
    @assert hobj != C_NULL
    obj = unsafe_load(hobj)
    
    topo = Object()
    
    @assert obj.type_>=0 && obj.type_<length(obj_types)
    topo.type_ = obj_types[obj.type_+1]
    
    topo.os_index = obj.os_index
    
    topo.name = obj.name == C_NULL ? "" : bytestring(obj.name)
    
    topo.attr = load_attr(obj.attr, topo.type_)
    
    topo.depth = obj.depth
    
    topo.logical_index = obj.logical_index
    
    topo.os_level = obj.os_level
    
    children = Array(hwloc_obj_t, obj.arity)
    ccall(:memcpy, Ptr{Void}, (Ptr{Void}, Ptr{Void}, Csize_t), children,
          obj.children, obj.arity*sizeof(Ptr{Void}))
    
    for child in children
        @assert child != C_NULL
        push!(topo.children, load(child))
    end
    
    return topo
end

function load_attr(hattr::Ptr{Void}, type_::Symbol)
    if type_==:System
        return NullAttr()
    elseif type_==:Machine
        return NullAttr()
    elseif type_==:Node
        return NullAttr()
    elseif type_==:Socket
        return NullAttr()
    elseif type_==:Cache
        ha = unsafe_load(convert(Ptr{hwloc_cache_attr_s}, hattr))
        return CacheAttr(ha.size, ha.depth, ha.linesize, ha.associativity,
                         cache_types[ha.type_+1])
    elseif type_==:Core
        return NullAttr()
    elseif type_==:PU
        return NullAttr()
    elseif type_==:Group
        error("not implemented")
    elseif type_==:Misc
        error("not implemented")
    elseif type_==:Bridge
        error("not implemented")
    elseif type_==:PCI_Device
        error("not implemented")
    elseif type_==:OS_Device
        error("not implemented")
    else
        error("Unsupported object type")
    end
end



# Condense information similar to hwloc-info
function info(obj::Object)
    maxdepth = mapreduce(obj->obj.depth, max, 0, obj)
    types = fill(:Error, maxdepth+1)
    foldl((_,obj)->(types[obj.depth+1] = obj.type_; nothing), nothing, obj)
    counts = fill(0, maxdepth+1)
    foldl((_,obj)->(counts[obj.depth+1] += 1; nothing), nothing, obj)
    return collect(zip(types, counts))
end



# Create a histogram
function hist_map(obj::Object)
    counts = Dict{Symbol,Int}([t=>0 for t in obj_types])
    foldl((_,obj)->(counts[obj.type_]+=1; nothing), nothing, obj)
    return counts
end

end
