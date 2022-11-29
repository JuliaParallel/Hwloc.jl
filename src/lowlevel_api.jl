using ..LibHwloc:
    hwloc_cpuset_t, hwloc_nodeset_t, hwloc_obj_type_t, hwloc_obj_cache_type_t,
    hwloc_obj_bridge_type_t, hwloc_obj_osdev_type_t, hwloc_distances_s,
    hwloc_obj, hwloc_obj_t, hwloc_obj_attr_u, hwloc_cache_attr_s,
    hwloc_group_attr_s, hwloc_pcidev_attr_s, hwloc_osdev_attr_s,
    hwloc_topology_t, hwloc_topology_init, hwloc_topology_load,
    hwloc_topology_get_depth, hwloc_get_nbobjs_by_depth,
    hwloc_get_obj_by_depth, hwloc_topology_destroy

# Compatibility constants:
const I1Cache = :L1ICache
const I2Cache = :L2ICache
const I3Cache = :L3ICache

# List of special capitalizations -- cenum_name_to_symbol will by default
# convert the all-uppcase C enum name to lowercase (with capitalized leading
# character). Any names listed here will be capitalized as stated below:
const special_capitalization = String[
    "PU", "L1Cache", "L2Cache", "L3Cache", "L4Cache", "L1ICache", "L2ICache",
    "L3ICache", "NUMANode", "PCI_Device", "OS_Device", "MemCache", "GPU", "DMA",
    "CoProc", "PIC"
]

function cenum_name_to_symbol(cenum_instance, prefix)
    full_name = replace(string(cenum_instance), prefix => "")
    if full_name in uppercase.(special_capitalization)
        idx = findfirst(
            x->x==full_name, uppercase.(special_capitalization)
        )
        return Symbol(special_capitalization[idx])
    end
    tail = lowercase(full_name[2:end])
    return Symbol(full_name[1]*tail)
end

obj_types = Symbol[]
for x in instances(hwloc_obj_type_t)
    push!(obj_types, cenum_name_to_symbol(x, "HWLOC_OBJ_"))
end

cache_types = Symbol[]
for x in instances(hwloc_obj_cache_type_t)
    push!(cache_types, cenum_name_to_symbol(x, "HWLOC_OBJ_CACHE_"))
end

# const bridge_types
bridge_types = Symbol[]
for x in instances(hwloc_obj_bridge_type_t)
    push!(cache_types, cenum_name_to_symbol(x, "HWLOC_OBJ_BRIDGE_"))
end

osdev_types = Symbol[]
for x in instances(hwloc_obj_osdev_type_t)
    push!(cache_types, cenum_name_to_symbol(x, "HWLOC_OBJ_OSDEV_"))
end

abstract type Attribute end

struct NullAttr <: Attribute
end
show(io::IO, a::NullAttr) = print(io, "")

struct CacheAttr <: Attribute
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

struct GroupAttr <: Attribute
    depth::Int
end
function show(io::IO, a::GroupAttr)
    print(io, "Group{depth=$(a.depth)}")
end

struct PCIDevAttr <: Attribute
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

struct OSDevAttr <: Attribute
    type_::Symbol
end
function show(io::IO, a::OSDevAttr)
    print(io, "OSDev{type=$(string(a.type_))}")
end

struct DieAttr <: Attribute
    depth::Int
end
function show(io::IO, a::DieAttr)
    print(io, "Die{depth=$(a.depth)}")
end

# type MemCacheAttr <: Attribute end

function load_attr(hattr::Ptr{hwloc_obj_attr_u}, type_::Symbol)
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
                    :L1ICache, :L2ICache, :L3ICache]
        ha = unsafe_load(convert(Ptr{hwloc_cache_attr_s}, hattr))
        return CacheAttr(ha.size, ha.depth, ha.linesize, ha.associativity,
                         cache_types[ha.type+1])
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




struct Object
    type_::Symbol
    os_index::Int
    name::String
    attr::Attribute
    mem::Int64

    depth::Int
    logical_index::Int
    # os_level::Int

    children::Vector{Object}

    memory_children::Vector{Object}

    # Object() = new(:Error, -1, "(nothing)", NullAttr(),
    #                0, -1, -1, # -1,
    #                Object[], Object[])
end

show(io::IO, obj::Object) = print(io, "Hwloc.Object: $(obj.type_)")

IteratorSize(::Type{Object}) = Base.SizeUnknown()
IteratorEltype(::Type{Object}) = Base.HasEltype()
eltype(::Type{Object}) = Object
isempty(::Object) = false
iterate(obj::Object) = (obj, isempty(obj.memory_children) ? obj.children : vcat(obj.memory_children, obj.children))
function iterate(::Object, state::Vector{Object})
    isempty(state) && return nothing
    # depth-first traversal
    # obj = shift!(state)
    obj, state = state[1], state[2:end]
    prepend!(state, obj.children)
    prepend!(state, obj.memory_children)
    return obj, state
end
# length(obj::Object) = mapreduce(x->1, +, obj)

attributes(obj::Object) = obj.attr
children(obj::Object) = obj.children


# Load topology for an object and all its children
function load(hobj::hwloc_obj_t)
    @assert hobj != C_NULL
    obj = unsafe_load(hobj)

    @assert Integer(obj.type)>=0 && Integer(obj.type)<length(obj_types)
    type_ = obj_types[obj.type+1]

    os_index = mod(obj.os_index, Cint)

    name = obj.name == C_NULL ? "" : unsafe_string(obj.name)

    attr = load_attr(obj.attr, type_)

    mem = Int64(obj.total_memory)

    depth = obj.depth

    logical_index = obj.logical_index

    # topo.os_level = obj.os_level

    obj_children = Vector{hwloc_obj_t}(UndefInitializer(), obj.arity)
    obj_children_r = Base.unsafe_convert(Ptr{hwloc_obj_t}, obj_children)
    unsafe_copyto!(obj_children_r, obj.children, obj.arity)

    children = Object[load(child) for child in obj_children]

    memory_children = Object[]
    if obj.memory_arity != C_NULL && obj.memory_first_child != C_NULL
        push!(memory_children, load(obj.memory_first_child))
    end

    topo = Object(type_, os_index, name, attr, mem, depth, logical_index, children, memory_children)
    return topo
end


"""
    topology_load() -> Hwloc.Object

Load the system topology by calling into libhwloc.
"""
function topology_load()
    htopop = Ref{hwloc_topology_t}()
    ierr = hwloc_topology_init(htopop)
    @assert ierr==0
    htopo = htopop[]
    ierr = hwloc_topology_load(htopo)
    @assert ierr==0

    depth = hwloc_topology_get_depth(htopo)
    @assert depth >= 1
    nroots = hwloc_get_nbobjs_by_depth(htopo, 0)
    @assert nroots == 1
    root = hwloc_get_obj_by_depth(htopo, 0, 0)
    topo = load(root)

    hwloc_topology_destroy(htopo)

    return topo
end
