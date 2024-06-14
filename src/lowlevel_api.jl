using ..LibHwloc:
    hwloc_cpuset_t, hwloc_nodeset_t, hwloc_obj_type_t, hwloc_obj_cache_type_t,
    hwloc_obj_bridge_type_t, hwloc_obj_osdev_type_t, hwloc_distances_s,
    hwloc_obj, hwloc_obj_t, hwloc_obj_attr_u, hwloc_cache_attr_s,
    hwloc_group_attr_s, hwloc_bridge_attr_s, hwloc_pcidev_attr_s,
    hwloc_osdev_attr_s, hwloc_topology_t, hwloc_topology_init,
    hwloc_topology_load, hwloc_topology_get_depth, hwloc_get_nbobjs_by_depth,
    hwloc_get_obj_by_depth, hwloc_topology_destroy, hwloc_type_filter_e,
    hwloc_topology_set_type_filter, hwloc_topology_get_type_filter,
    hwloc_topology_set_all_types_filter, hwloc_topology_set_cache_types_filter,
    hwloc_topology_set_icache_types_filter, hwloc_topology_set_io_types_filter,
    hwloc_topology_set_userdata, hwloc_topology_get_userdata, var"##Ctag#349",
    var"##Ctag#350", hwloc_cpukinds_get_nr, hwloc_bitmap_alloc, hwloc_bitmap_alloc_full,
    hwloc_bitmap_free, hwloc_cpukinds_get_by_cpuset, hwloc_bitmap_from_ulong,
    hwloc_cpukinds_get_info, hwloc_info_s, hwloc_bitmap_to_ulong, hwloc_bitmap_nr_ulongs,
    hwloc_topology_get_topology_cpuset, hwloc_bitmap_to_ulongs

using ..LibHwlocExtensions:
    hwloc_pci_class_string

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
            x -> x == full_name, uppercase.(special_capitalization)
        )
        return Symbol(special_capitalization[idx])
    end
    tail = lowercase(full_name[2:end])
    return Symbol(full_name[1] * tail)
end

obj_types = Symbol[]
for x in instances(hwloc_obj_type_t)
    push!(obj_types, cenum_name_to_symbol(x, "HWLOC_OBJ_"))
end

cache_types = Symbol[]
for x in instances(hwloc_obj_cache_type_t)
    push!(cache_types, cenum_name_to_symbol(x, "HWLOC_OBJ_CACHE_"))
end

bridge_types = Symbol[]
for x in instances(hwloc_obj_bridge_type_t)
    push!(bridge_types, cenum_name_to_symbol(x, "HWLOC_OBJ_BRIDGE_"))
end

osdev_types = Symbol[]
for x in instances(hwloc_obj_osdev_type_t)
    push!(osdev_types, cenum_name_to_symbol(x, "HWLOC_OBJ_OSDEV_"))
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
    print(
        io,
        "Cache{size=$(a.size), " *
        "depth=$(a.depth), " *
        "linesize=$(a.linesize), " *
        "associativity=$(a.associativity), " *
        "type=$(string(a.type_))}"
    )
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
function PCIDevAttr(ha::hwloc_pcidev_attr_s)
    return PCIDevAttr(
        ha.domain, ha.bus, ha.dev, ha.func, ha.class_id, ha.vendor_id,
        ha.device_id, ha.subvendor_id, ha.subdevice_id, ha.revision,
        ha.linkspeed
    )
end
function show(io::IO, a::PCIDevAttr)
    print(
        io,
        "PCIDev(domain=$(a.domain), " *
        "bus=$(a.bus), " *
        "dev=$(a.dev), " *
        "func=$(a.func), " *
        "class_id=$(hwloc_pci_class_string(a.class_id)), " *
        "vendor_id=$(a.vendor_id), " *
        "device_id=$(a.device_id), " *
        "subvendor_id=$(a.subvendor_id), " *
        "subdevice_id=$(a.subdevice_id), " *
        "revision=$(a.revision), " *
        "linkspeed=$(a.linkspeed))"
    )
end

struct BridgeAttr <: Attribute
    upstream::var"##Ctag#349"
    upstream_type::hwloc_obj_bridge_type_t
    downstream::var"##Ctag#350"
    downstream_type::hwloc_obj_bridge_type_t
    depth::UInt
end
function BridgeAttr(ha::hwloc_bridge_attr_s)
    return BridgeAttr(
        ha.upstream, ha.upstream_type,
        ha.downstream, ha.downstream_type,
        ha.depth
    )
end
function show(io::IO, a::BridgeAttr)
    print(
        io,
        "BridgeAttr(US=$(hwloc_pci_class_string(a.upstream.pci.class_id)), " *
        "upstream_type=$(string(a.upstream_type)), " *
        "downstream_type=$(string(a.downstream_type)) " *
        ")"
    )
end

struct OSDevAttr <: Attribute
    type::hwloc_obj_osdev_type_t
end
function show(io::IO, a::OSDevAttr)
    print(io, "OSDev{type=$(string(a.type))}")
end

struct DieAttr <: Attribute
    depth::Int
end
function show(io::IO, a::DieAttr)
    print(io, "Die{depth=$(a.depth)}")
end

# type MemCacheAttr <: Attribute end

function load_attr(hattr::Ptr{hwloc_obj_attr_u}, type_::Symbol)
    if type_ == :System
        return NullAttr()
    elseif type_ == :Machine
        return NullAttr()
    elseif type_ == :Package
        return NullAttr()
    elseif type_ ∈ [:Node, :NUMANode]
        return NullAttr()
    elseif type_ == :Socket
        return NullAttr()
    elseif type_ ∈ [:Cache, :L1Cache, :L2Cache, :L3Cache, :L4Cache, :L5Cache,
        :L1ICache, :L2ICache, :L3ICache]
        ha = unsafe_load(convert(Ptr{hwloc_cache_attr_s}, hattr))
        return CacheAttr(ha.size, ha.depth, ha.linesize, ha.associativity,
            cache_types[ha.type+1])
    elseif type_ == :Core
        return NullAttr()
    elseif type_ == :PU
        return NullAttr()
    elseif type_ == :Group
        ha = unsafe_load(convert(Ptr{hwloc_group_attr_s}, hattr))
        return GroupAttr(ha.depth)
    elseif type_ == :Misc
        error("not implemented")
    elseif type_ == :Bridge
        ha = unsafe_load(convert(Ptr{hwloc_bridge_attr_s}, hattr))
        return BridgeAttr(ha)
    elseif type_ == :PCI_Device
        ha = unsafe_load(convert(Ptr{hwloc_pcidev_attr_s}, hattr))
        return PCIDevAttr(ha)
    elseif type_ == :OS_Device
        ha = unsafe_load(convert(Ptr{hwloc_obj_osdev_type_t}, hattr))
        return OSDevAttr(ha)
    elseif type_ == :Die
        ha = unsafe_load(convert(Ptr{hwloc_cache_attr_s}, hattr))
        return DieAttr(ha.depth)
    elseif type_ == :MemCache
        error("not implemented")
    else
        error("Unsupported object type $type_")
    end
end


struct Object
    type_::Symbol
    subtype::String
    os_index::Int
    name::String
    attr::Attribute
    mem::Int64

    depth::Int
    logical_index::Int
    # os_level::Int

    children::Vector{Object}

    memory_children::Vector{Object}

    io_children::Vector{Object}

    # Object() = new(:Error, -1, "(nothing)", NullAttr(),
    #                0, -1, -1, # -1,
    #                Object[], Object[])
end

show(io::IO, obj::Object) = print(io, "Hwloc.Object: $(obj.type_)")

IteratorSize(::Type{Object}) = Base.SizeUnknown()
IteratorEltype(::Type{Object}) = Base.HasEltype()
eltype(::Type{Object}) = Object
isempty(::Object) = false
function iterate(obj::Object)
    state = vcat(obj.memory_children, obj.children, obj.io_children)
    return obj, state
end
function iterate(::Object, state::Vector{Object})
    isempty(state) && return nothing
    # depth-first traversal
    # obj = shift!(state)
    obj, state = state[1], state[2:end]
    # prepend! children groups to state so that they will be iterated before
    # siblings.  The iteration order is memory_children, children, io_children
    # to match lstopo ordering, but we must prepend! in the opposite order to
    # ensure that memory_children are iterated first.
    prepend!(state, obj.io_children)
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

    @assert Integer(obj.type) >= 0 && Integer(obj.type) < length(obj_types)
    type_ = obj_types[obj.type+1]
    subtype = obj.subtype == C_NULL ? "" : unsafe_string(obj.subtype)

    os_index = mod(obj.os_index, Cint)

    name = obj.name == C_NULL ? "" : unsafe_string(obj.name)

    attr = load_attr(obj.attr, type_)

    mem = Int64(obj.total_memory)

    depth = obj.depth

    logical_index = obj.logical_index

    # topo.os_level = obj.os_level

    children = Object[
        load(child)
        for child in unsafe_wrap(Vector{hwloc_obj_t}, obj.children, obj.arity)
    ]

    memory_children = Object[]
    if obj.memory_arity != 0
        memory_child = obj.memory_first_child
        while memory_child != C_NULL
            push!(memory_children, load(memory_child))
            memory_child = unsafe_load(memory_child).next_sibling
        end
    end

    io_children = Object[]
    if obj.io_arity != 0
        io_child = obj.io_first_child
        while io_child != C_NULL
            push!(io_children, load(io_child))
            io_child = unsafe_load(io_child).next_sibling
        end
    end

    # not needed for now -- unless we want to start putting things (like
    # processes into the Hwloc tree)
    # misc_children = Object[]
    # if obj.misc_arity != 0
    #     misc_child = obj.misc_first_child
    #     while misc_child != C_NULL
    #         push!(misc_children, load(misc_child))
    #         misc_child = unsafe_load(misc_child).next_sibling
    #     end
    # end

    topo = Object(
        type_, subtype, os_index, name, attr, mem, depth, logical_index,
        children, memory_children, io_children
    )
    return topo
end


"""
    topology_init(;io=true)

Init underlying Hwloc objec, and set the type filter to
HWLOC_TYPE_FILTER_KEEP_ALL if `io==true`
"""
function topology_init(; io=true)
    r_htopo = Ref{hwloc_topology_t}()
    hwloc_topology_init(r_htopo)
    if io
        hwloc_topology_set_io_types_filter(
            r_htopo[], LibHwloc.HWLOC_TYPE_FILTER_KEEP_ALL
        )
    end
    return r_htopo[]
end


function get_type_filter(topology, object_type)
    r_type_filter = Ref{hwloc_type_filter_e}()
    ierr = hwloc_topology_get_type_filter(topology, object_type, r_type_filter)
    @assert ierr == 0
    return r_type_filter[]
end

function withbitmap(f; full=false)
    bm = full ? hwloc_bitmap_alloc_full() : hwloc_bitmap_alloc()
    try
        f(bm)
    finally
        hwloc_bitmap_free(bm)
    end
end

"""
Return the \"cpu kind\" of the `i`th core (`0 < i <= hwloc_cpukinds_get_nr(htopo, 0)`)
"""
function cpukind_of_ith_core(htopo, i)
    mask = Culong(0) | (1 << (i - 1))
    local cpukind
    withbitmap() do bm
        hwloc_bitmap_from_ulong(bm, mask)
        cpukind = hwloc_cpukinds_get_by_cpuset(htopo, bm, 0)
    end
    return cpukind
end

function ith_in_mask(mask::Culong, i::Integer)
    # i starts at 1
    imask = Culong(0) | (1 << (i - 1))
    return !iszero(mask & imask)
end

count_set_bits(mask::Culong) = count(i -> ith_in_mask(mask, i), 1:64)

"""
Get information of cores of the same cpukind. `kind_index` starts at 1.
"""
function get_info_same_cpukind(htopo, kind_index)
    cpuset = hwloc_topology_get_topology_cpuset(htopo)
    withbitmap() do bm
        infos = Ref{Ptr{hwloc_info_s}}()
        efficiency = Ref{Cint}()
        nr_infos = Ref{Cuint}()
        ret = hwloc_cpukinds_get_info(htopo, kind_index - 1, bm, efficiency, nr_infos, infos, 0)
        if ret != 0
            return nothing
        end

        nrcpuset =  hwloc_bitmap_nr_ulongs(cpuset) # number of ulongs needed to represent all possible bitmaps
        nrbitmap =  hwloc_bitmap_nr_ulongs(bm) # number of ulongs needed to represent all possible bitmaps
        @show nrcpuset, nrbitmap
        # hwloc_bitmap_to_ulongs(bm)

        # The lower the efficiency rank the more efficient the core.
        # For example, we expect efficiency_rank=0 for efficiency cores and
        # efficiency_rank=1 for performance cores (if there's two kinds of cores).
        return (; mask=hwloc_bitmap_to_ulong(bm), efficiency_rank=efficiency[])
    end
end

const _cpukindinfo = Ref{Union{Nothing,Vector{Union{Nothing,@NamedTuple{mask::UInt64, efficiency_rank::Int32}}}}}(nothing)

function get_cpukind_info()
    isnothing(_cpukindinfo[]) && topology_load()
    return _cpukindinfo[]
end

"""
    topology_load() -> Hwloc.Object

Load the system topology by calling into libhwloc.
"""
function topology_load(htopo=topology_init())
    ierr = hwloc_topology_load(htopo)
    @assert ierr == 0

    depth = hwloc_topology_get_depth(htopo)
    @assert depth >= 1
    nroots = hwloc_get_nbobjs_by_depth(htopo, 0)
    @assert nroots == 1
    root = hwloc_get_obj_by_depth(htopo, 0, 0)
    topo = load(root)

    ncpukinds = hwloc_cpukinds_get_nr(htopo, 0)
    if ncpukinds > 0
        # more than one CPU kind detected
        # @show cpukind_of_ith_core(htopo, 1)
        # @show cpukind_of_ith_core(htopo, 6)
        _cpukindinfo[] = [get_info_same_cpukind(htopo, kind_index) for kind_index in 1:ncpukinds]
    else
        _cpukindinfo[] = [nothing]
    end

    hwloc_topology_destroy(htopo)
    return topo
end
