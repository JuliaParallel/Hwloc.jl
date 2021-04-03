module Hwloc
using Hwloc_jll

import Base: show
import Base: IteratorSize, IteratorEltype, isempty, eltype, iterate

export get_api_version, topology_load, getinfo, histmap, num_physical_cores
export collectobjects, attributes, num_packages, l3cache_sizes, l2cache_sizes, l1cache_sizes

function get_api_version()
    version = ccall((:hwloc_get_api_version, libhwloc), Cuint, ())
    patch = version % 256
    version = version ÷ 256
    minor = version % 256
    version = version ÷ 256
    major = version
    VersionNumber(major, minor, patch)
end
const api_version = get_api_version()



# Note: These must correspond to <hwloc.h>

const hwloc_bitmap_t = Ptr{Cvoid}
const hwloc_cpuset_t = hwloc_bitmap_t
const hwloc_nodeset_t = hwloc_bitmap_t

const hwloc_obj_type_t = Cint
const hwloc_obj_cache_type_t = Cint
const hwloc_obj_bridge_type_t = Cint
const hwloc_obj_osdev_type_t = Cint

# Note: The order of these declaration must correspond to then enums
# in <hwloc.h>
const obj_types =
    Symbol[:Machine, :Package, :Core, :PU, :L1Cache, :L2Cache, :L3Cache,
           :L4Cache, :L5Cache, :I1Cache, :I2Cache, :I3Cache, :Group, :NUMANode,
           :Bridge, :PCI_Device, :OS_Device, :Misc, :MemCache, :Die, :Error]
const cache_types =
    Symbol[:Unified, :Data, :Instruction]
# const bridge_types
const osdev_types =
    Symbol[:Block, :GPU, :Network, :Openfabrics, :DMA, :CoProc]



struct hwloc_obj_memory_page_type_s
    size::Culonglong
    count::Culonglong
end

struct hwloc_obj_memory_s
    total_memory::Culonglong
    local_memory::Culonglong
    page_types_len::Cuint
    page_types::Ptr{hwloc_obj_memory_page_type_s}
end

struct hwloc_distances_s
    relative_depth::Cuint
    nbobjs::Cuint
    latency::Ptr{Cfloat}
    latency_max::Cfloat
    latency_base::Cfloat
end

struct hwloc_obj_info_s
    name::Ptr{Cchar}
    value::Ptr{Cchar}
end

struct hwloc_obj
    # physical information
    type_::hwloc_obj_type_t
    subtype::Ptr{Cchar}
    os_index::Cuint             # (unsigned)-1 if unknown
    name::Ptr{Cchar}
    total_memory::Culonglong
    attr::Ptr{Cvoid}             # Ptr{hwloc_obj_attr_u}

    # global position
    depth::Cint
    logical_index::Cuint

    # cousins
    next_cousin::Ptr{hwloc_obj}
    prev_cousin::Ptr{hwloc_obj}

    # parent
    parent::Ptr{hwloc_obj}

    # siblings
    sibling_rank::Cuint
    next_sibling::Ptr{hwloc_obj}
    prev_sibling::Ptr{hwloc_obj}

    # children
    arity::Cuint
    children::Ptr{Ptr{hwloc_obj}}
    first_child::Ptr{hwloc_obj}
    last_child::Ptr{hwloc_obj}

    # symmetry
    symmetric_subtree::Cint

    # memory
    memory_arity::Cuint
    memory_first_child::Ptr{hwloc_obj}

    # I/O
    io_arity::Cuint
    io_first_child::Ptr{hwloc_obj}

    # misc
    misc_arity::Cuint
    misc_first_child::Ptr{hwloc_obj}

    # cpusets and nodesets
    cpuset::hwloc_cpuset_t
    complete_cpuset::hwloc_cpuset_t
    nodeset::hwloc_cpuset_t
    complete_nodeset::hwloc_cpuset_t

    # infos
    infos::Ptr{hwloc_obj_info_s}
    infos_count::Cuint

    # misc
    userdata::Ptr{Cvoid}

    # global
    gp_index::Culonglong
end

const hwloc_obj_t = Ptr{hwloc_obj}

struct hwloc_cache_attr_s
    size::Culonglong
    depth::Cuint
    linesize::Cuint
    associativity::Cint
    type_::hwloc_obj_cache_type_t
end

struct hwloc_group_attr_s
    depth::Cuint
end

struct hwloc_pcidev_attr_s
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

struct hwloc_osdev_attr_s
    type_::hwloc_obj_osdev_type_t
end



abstract type Attribute end

mutable struct NullAttr <: Attribute
end
show(io::IO, a::NullAttr) = print(io, "")

mutable struct CacheAttr <: Attribute
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

mutable struct GroupAttr <: Attribute
    depth::Int
end
function show(io::IO, a::GroupAttr)
    print(io, "Group{depth=$(a.depth)}")
end

mutable struct PCIDevAttr <: Attribute
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

mutable struct OSDevAttr <: Attribute
    type_::Symbol
end
function show(io::IO, a::OSDevAttr)
    print(io, "OSDev{type=$(string(a.type_))}")
end

mutable struct DieAttr <: Attribute
    depth::Int
end
function show(io::IO, a::DieAttr)
    print(io, "Die{depth=$(a.depth)}")
end

# type MemCacheAttr <: Attribute end



mutable struct Object
    type_::Symbol
    os_index::Int
    name::String
    attr::Attribute
    mem::UInt

    depth::Int
    logical_index::Int
    # os_level::Int

    children::Vector{Object}
    
    memory_children::Vector{Object}

    Object() = new(:Error, -1, "(nothing)", NullAttr(),
                   0, -1, -1, # -1,
                   Object[], Object[])
end

IteratorSize(::Type{Object}) = Base.SizeUnknown()
IteratorEltype(::Type{Object}) = Base.HasEltype()
eltype(::Type{Object}) = Object
isempty(::Object) = false
iterate(obj::Object) = (obj, isempty(obj.memory_children) ? obj.children : vcat(obj.children, obj.memory_children))
function iterate(::Object, state::Vector{Object})
    isempty(state) && return nothing
    # depth-first traversal
    # obj = shift!(state)
    obj, state = state[1], state[2:end]
    prepend!(state, obj.children, obj.memory_children)
    return obj, state
end
# length(obj::Object) = mapreduce(x->1, +, obj)

function bytes2string(x::Integer)
    y = float(x)
    if y > 1023
        y = y / 1024
        if y > 1023
            y = y / 1024
            if y > 1023
                return string(round(y / 1024, digits=2), " GB")
            else
                return string(round(y, digits=2), " MB")
            end
        else
            return string(round(y, digits=2), " KB")    
        end
    else
        return string(round(y, digits=2), " B")
    end
end

function show(io::IO, obj::Object)
    idxstr = obj.type_ in (:Package, :Core, :PU) ? "L#$(obj.logical_index) P#$(obj.os_index) " : ""
    attrstr = string(obj.attr)

    if obj.type_ in (:L1Cache, :L2Cache, :L3Cache)
        tstr = first(string(obj.type_), 2)
        attrstr = "("*bytes2string(obj.attr.size)*")"
    else
        tstr = string(obj.type_)
    end

    println(io, repeat(" ", 4*max(0,obj.depth)), tstr, " ",
        idxstr,
        attrstr, obj.mem > 0 ? "("*bytes2string(obj.mem)*")" : "")

    for memchild in obj.memory_children
        memstr = "("*bytes2string(memchild.mem)*")"
        println(io, repeat(" ", 4*max(0,obj.depth) + 4), string(memchild.type_), " ", memstr)
    end

    for child in obj.children
        show(io, child)
    end
end



function topology_load()
    htopop = Ref{Ptr{Cvoid}}()
    ierr = ccall((:hwloc_topology_init, libhwloc), Cint, (Ptr{Cvoid},), htopop)
    @assert ierr==0
    htopo = htopop[]
    ierr = ccall((:hwloc_topology_load, libhwloc), Cint, (Ptr{Cvoid},), htopo)
    @assert ierr==0

    depth = ccall((:hwloc_topology_get_depth, libhwloc), Cint, (Ptr{Cvoid},),
                  htopo)
    @assert depth >= 1
    nroots = ccall((:hwloc_get_nbobjs_by_depth, libhwloc), Cint,
                   (Ptr{Cvoid}, Cuint), htopo, 0)
    @assert nroots == 1
    root = ccall((:hwloc_get_obj_by_depth, libhwloc), hwloc_obj_t,
                 (Ptr{Cvoid}, Cuint, Cuint), htopo, 0, 0)
    topo = load(root)

    ccall((:hwloc_topology_destroy, libhwloc), Cvoid, (Ptr{Cvoid},), htopo)

    return topo
end

# Load topology for an object and all its children
function load(hobj::hwloc_obj_t)
    @assert hobj != C_NULL
    obj = unsafe_load(hobj)

    topo = Object()

    @assert obj.type_>=0 && obj.type_<length(obj_types)
    topo.type_ = obj_types[obj.type_+1]

    topo.os_index = mod(obj.os_index, Cint)

    topo.name = obj.name == C_NULL ? "" : unsafe_string(obj.name)

    topo.attr = load_attr(obj.attr, topo.type_)

    topo.mem = UInt(obj.total_memory)

    topo.depth = obj.depth

    topo.logical_index = obj.logical_index

    # topo.os_level = obj.os_level

    children = Vector{hwloc_obj_t}(UndefInitializer(), obj.arity)
    ccall(:memcpy, Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), children,
          obj.children, obj.arity*sizeof(Ptr{Cvoid}))

    for child in children
        @assert child != C_NULL
        push!(topo.children, load(child))
    end

    if obj.memory_arity != C_NULL && obj.memory_first_child != C_NULL
        push!(topo.memory_children, load(obj.memory_first_child))
    end

    return topo
end

function load_attr(hattr::Ptr{Cvoid}, type_::Symbol)
    if type_==:System
        return NullAttr()
    elseif type_==:Machine
        return NullAttr()
    elseif type_==:Package
        return NullAttr()
    elseif type_ ∈ [:Node, :NUMANode]
        return NullAttr()
    elseif type_==:Socket
        return NullAttr()
    elseif type_ ∈ [:Cache, :L1Cache, :L2Cache, :L3Cache, :L4Cache, :L5Cache,
                    :I1Cache, :I2Cache, :I3Cache]
        ha = unsafe_load(convert(Ptr{hwloc_cache_attr_s}, hattr))
        return CacheAttr(ha.size, ha.depth, ha.linesize, ha.associativity,
                         cache_types[ha.type_+1])
    elseif type_==:Core
        return NullAttr()
    elseif type_==:PU
        return NullAttr()
    elseif type_==:Group
        ha = unsafe_load(convert(Ptr{hwloc_group_attr_s}, hattr))
        return GroupAttr(ha.depth)
    elseif type_==:Misc
        error("not implemented")
    elseif type_==:Bridge
        error("not implemented")
    elseif type_==:PCI_Device
        error("not implemented")
    elseif type_==:OS_Device
        error("not implemented")
    elseif type_==:Die
        ha = unsafe_load(convert(Ptr{hwloc_cache_attr_s}, hattr))
        return DieAttr(ha.depth)
    elseif type_==:MemCache
        error("not implemented")
    else
        error("Unsupported object type $type_")
    end
end

###########################################################
# High level API

# Condense information similar to hwloc-info
function getinfo(obj::Object)
    maxdepth = mapreduce(obj->obj.depth, max, obj; init=0)
    types_counts = fill((:Error, 0), maxdepth+1)
    for subobj in obj
        _, oldcount = types_counts[subobj.depth+1]
        types_counts[subobj.depth+1] = (subobj.type_, oldcount + 1)
    end
    return types_counts
end


# Create a histogram
function histmap(obj::Object)
    counts = Dict{Symbol,Int}([(t, 0) for t in obj_types])
    for subobj in obj
        counts[subobj.type_] += 1
    end
    return counts
end


# Collect objects of given type from topology.
collectobjects(t::Object, type_::Symbol) = collect(Iterators.filter(obj -> obj.type_ == type_, t))

attributes(obj::Object)=obj.attr

# Return number of cores
function num_physical_cores()
  topo = topology_load()
  histmap(topo)[:Core]
end


# Return number of processor packages (sockets). Compute servers usually consist
# of several packages which in turn contain several cores.
num_packages() = count(obj->obj.type_ == :Package, Hwloc.topology_load())

# Return L3 cache sizes (in Bytes) of each package.
# Usually, L3 cache is shared by all cores in a package. 
l3cache_sizes() = map(obj->obj.attr.size, Iterators.filter(obj->obj.type_ == :L3Cache, Hwloc.topology_load()))

# Return L2 cache sizes (in Bytes) of each core.
l2cache_sizes() = map(obj->obj.attr.size, Iterators.filter(obj->obj.type_ == :L2Cache, Hwloc.topology_load()))

# Return L1 cache sizes (in Bytes) of each core.
l1cache_sizes() = map(obj->obj.attr.size, Iterators.filter(obj->obj.type_ == :L1Cache, Hwloc.topology_load()))

end
