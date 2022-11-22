module LibHwloc

using Hwloc_jll
export Hwloc_jll

using CEnum

const __pid_t = Cint

const pid_t = __pid_t

const pthread_t = Culong

mutable struct hwloc_bitmap_s end

const hwloc_const_bitmap_t = Ptr{hwloc_bitmap_s}

function hwloc_bitmap_weight(bitmap)
    ccall((:hwloc_bitmap_weight, libhwloc), Cint, (hwloc_const_bitmap_t,), bitmap)
end

function hwloc_bitmap_first(bitmap)
    ccall((:hwloc_bitmap_first, libhwloc), Cint, (hwloc_const_bitmap_t,), bitmap)
end

function hwloc_bitmap_next(bitmap, prev)
    ccall((:hwloc_bitmap_next, libhwloc), Cint, (hwloc_const_bitmap_t, Cint), bitmap, prev)
end

const hwloc_uint64_t = UInt64

const hwloc_bitmap_t = Ptr{hwloc_bitmap_s}

function hwloc_bitmap_alloc()
    ccall((:hwloc_bitmap_alloc, libhwloc), hwloc_bitmap_t, ())
end

function hwloc_bitmap_alloc_full()
    ccall((:hwloc_bitmap_alloc_full, libhwloc), hwloc_bitmap_t, ())
end

function hwloc_bitmap_free(bitmap)
    ccall((:hwloc_bitmap_free, libhwloc), Cvoid, (hwloc_bitmap_t,), bitmap)
end

function hwloc_bitmap_dup(bitmap)
    ccall((:hwloc_bitmap_dup, libhwloc), hwloc_bitmap_t, (hwloc_const_bitmap_t,), bitmap)
end

function hwloc_bitmap_copy(dst, src)
    ccall((:hwloc_bitmap_copy, libhwloc), Cint, (hwloc_bitmap_t, hwloc_const_bitmap_t), dst, src)
end

function hwloc_bitmap_snprintf(buf, buflen, bitmap)
    ccall((:hwloc_bitmap_snprintf, libhwloc), Cint, (Ptr{Cchar}, Csize_t, hwloc_const_bitmap_t), buf, buflen, bitmap)
end

function hwloc_bitmap_asprintf(strp, bitmap)
    ccall((:hwloc_bitmap_asprintf, libhwloc), Cint, (Ptr{Ptr{Cchar}}, hwloc_const_bitmap_t), strp, bitmap)
end

function hwloc_bitmap_sscanf(bitmap, string)
    ccall((:hwloc_bitmap_sscanf, libhwloc), Cint, (hwloc_bitmap_t, Ptr{Cchar}), bitmap, string)
end

function hwloc_bitmap_list_snprintf(buf, buflen, bitmap)
    ccall((:hwloc_bitmap_list_snprintf, libhwloc), Cint, (Ptr{Cchar}, Csize_t, hwloc_const_bitmap_t), buf, buflen, bitmap)
end

function hwloc_bitmap_list_asprintf(strp, bitmap)
    ccall((:hwloc_bitmap_list_asprintf, libhwloc), Cint, (Ptr{Ptr{Cchar}}, hwloc_const_bitmap_t), strp, bitmap)
end

function hwloc_bitmap_list_sscanf(bitmap, string)
    ccall((:hwloc_bitmap_list_sscanf, libhwloc), Cint, (hwloc_bitmap_t, Ptr{Cchar}), bitmap, string)
end

function hwloc_bitmap_taskset_snprintf(buf, buflen, bitmap)
    ccall((:hwloc_bitmap_taskset_snprintf, libhwloc), Cint, (Ptr{Cchar}, Csize_t, hwloc_const_bitmap_t), buf, buflen, bitmap)
end

function hwloc_bitmap_taskset_asprintf(strp, bitmap)
    ccall((:hwloc_bitmap_taskset_asprintf, libhwloc), Cint, (Ptr{Ptr{Cchar}}, hwloc_const_bitmap_t), strp, bitmap)
end

function hwloc_bitmap_taskset_sscanf(bitmap, string)
    ccall((:hwloc_bitmap_taskset_sscanf, libhwloc), Cint, (hwloc_bitmap_t, Ptr{Cchar}), bitmap, string)
end

function hwloc_bitmap_zero(bitmap)
    ccall((:hwloc_bitmap_zero, libhwloc), Cvoid, (hwloc_bitmap_t,), bitmap)
end

function hwloc_bitmap_fill(bitmap)
    ccall((:hwloc_bitmap_fill, libhwloc), Cvoid, (hwloc_bitmap_t,), bitmap)
end

function hwloc_bitmap_only(bitmap, id)
    ccall((:hwloc_bitmap_only, libhwloc), Cint, (hwloc_bitmap_t, Cuint), bitmap, id)
end

function hwloc_bitmap_allbut(bitmap, id)
    ccall((:hwloc_bitmap_allbut, libhwloc), Cint, (hwloc_bitmap_t, Cuint), bitmap, id)
end

function hwloc_bitmap_from_ulong(bitmap, mask)
    ccall((:hwloc_bitmap_from_ulong, libhwloc), Cint, (hwloc_bitmap_t, Culong), bitmap, mask)
end

function hwloc_bitmap_from_ith_ulong(bitmap, i, mask)
    ccall((:hwloc_bitmap_from_ith_ulong, libhwloc), Cint, (hwloc_bitmap_t, Cuint, Culong), bitmap, i, mask)
end

function hwloc_bitmap_from_ulongs(bitmap, nr, masks)
    ccall((:hwloc_bitmap_from_ulongs, libhwloc), Cint, (hwloc_bitmap_t, Cuint, Ptr{Culong}), bitmap, nr, masks)
end

function hwloc_bitmap_set(bitmap, id)
    ccall((:hwloc_bitmap_set, libhwloc), Cint, (hwloc_bitmap_t, Cuint), bitmap, id)
end

function hwloc_bitmap_set_range(bitmap, _begin, _end)
    ccall((:hwloc_bitmap_set_range, libhwloc), Cint, (hwloc_bitmap_t, Cuint, Cint), bitmap, _begin, _end)
end

function hwloc_bitmap_set_ith_ulong(bitmap, i, mask)
    ccall((:hwloc_bitmap_set_ith_ulong, libhwloc), Cint, (hwloc_bitmap_t, Cuint, Culong), bitmap, i, mask)
end

function hwloc_bitmap_clr(bitmap, id)
    ccall((:hwloc_bitmap_clr, libhwloc), Cint, (hwloc_bitmap_t, Cuint), bitmap, id)
end

function hwloc_bitmap_clr_range(bitmap, _begin, _end)
    ccall((:hwloc_bitmap_clr_range, libhwloc), Cint, (hwloc_bitmap_t, Cuint, Cint), bitmap, _begin, _end)
end

function hwloc_bitmap_singlify(bitmap)
    ccall((:hwloc_bitmap_singlify, libhwloc), Cint, (hwloc_bitmap_t,), bitmap)
end

function hwloc_bitmap_to_ulong(bitmap)
    ccall((:hwloc_bitmap_to_ulong, libhwloc), Culong, (hwloc_const_bitmap_t,), bitmap)
end

function hwloc_bitmap_to_ith_ulong(bitmap, i)
    ccall((:hwloc_bitmap_to_ith_ulong, libhwloc), Culong, (hwloc_const_bitmap_t, Cuint), bitmap, i)
end

function hwloc_bitmap_to_ulongs(bitmap, nr, masks)
    ccall((:hwloc_bitmap_to_ulongs, libhwloc), Cint, (hwloc_const_bitmap_t, Cuint, Ptr{Culong}), bitmap, nr, masks)
end

function hwloc_bitmap_nr_ulongs(bitmap)
    ccall((:hwloc_bitmap_nr_ulongs, libhwloc), Cint, (hwloc_const_bitmap_t,), bitmap)
end

function hwloc_bitmap_isset(bitmap, id)
    ccall((:hwloc_bitmap_isset, libhwloc), Cint, (hwloc_const_bitmap_t, Cuint), bitmap, id)
end

function hwloc_bitmap_iszero(bitmap)
    ccall((:hwloc_bitmap_iszero, libhwloc), Cint, (hwloc_const_bitmap_t,), bitmap)
end

function hwloc_bitmap_isfull(bitmap)
    ccall((:hwloc_bitmap_isfull, libhwloc), Cint, (hwloc_const_bitmap_t,), bitmap)
end

function hwloc_bitmap_last(bitmap)
    ccall((:hwloc_bitmap_last, libhwloc), Cint, (hwloc_const_bitmap_t,), bitmap)
end

function hwloc_bitmap_first_unset(bitmap)
    ccall((:hwloc_bitmap_first_unset, libhwloc), Cint, (hwloc_const_bitmap_t,), bitmap)
end

function hwloc_bitmap_next_unset(bitmap, prev)
    ccall((:hwloc_bitmap_next_unset, libhwloc), Cint, (hwloc_const_bitmap_t, Cint), bitmap, prev)
end

function hwloc_bitmap_last_unset(bitmap)
    ccall((:hwloc_bitmap_last_unset, libhwloc), Cint, (hwloc_const_bitmap_t,), bitmap)
end

function hwloc_bitmap_or(res, bitmap1, bitmap2)
    ccall((:hwloc_bitmap_or, libhwloc), Cint, (hwloc_bitmap_t, hwloc_const_bitmap_t, hwloc_const_bitmap_t), res, bitmap1, bitmap2)
end

function hwloc_bitmap_and(res, bitmap1, bitmap2)
    ccall((:hwloc_bitmap_and, libhwloc), Cint, (hwloc_bitmap_t, hwloc_const_bitmap_t, hwloc_const_bitmap_t), res, bitmap1, bitmap2)
end

function hwloc_bitmap_andnot(res, bitmap1, bitmap2)
    ccall((:hwloc_bitmap_andnot, libhwloc), Cint, (hwloc_bitmap_t, hwloc_const_bitmap_t, hwloc_const_bitmap_t), res, bitmap1, bitmap2)
end

function hwloc_bitmap_xor(res, bitmap1, bitmap2)
    ccall((:hwloc_bitmap_xor, libhwloc), Cint, (hwloc_bitmap_t, hwloc_const_bitmap_t, hwloc_const_bitmap_t), res, bitmap1, bitmap2)
end

function hwloc_bitmap_not(res, bitmap)
    ccall((:hwloc_bitmap_not, libhwloc), Cint, (hwloc_bitmap_t, hwloc_const_bitmap_t), res, bitmap)
end

function hwloc_bitmap_intersects(bitmap1, bitmap2)
    ccall((:hwloc_bitmap_intersects, libhwloc), Cint, (hwloc_const_bitmap_t, hwloc_const_bitmap_t), bitmap1, bitmap2)
end

function hwloc_bitmap_isincluded(sub_bitmap, super_bitmap)
    ccall((:hwloc_bitmap_isincluded, libhwloc), Cint, (hwloc_const_bitmap_t, hwloc_const_bitmap_t), sub_bitmap, super_bitmap)
end

function hwloc_bitmap_isequal(bitmap1, bitmap2)
    ccall((:hwloc_bitmap_isequal, libhwloc), Cint, (hwloc_const_bitmap_t, hwloc_const_bitmap_t), bitmap1, bitmap2)
end

function hwloc_bitmap_compare_first(bitmap1, bitmap2)
    ccall((:hwloc_bitmap_compare_first, libhwloc), Cint, (hwloc_const_bitmap_t, hwloc_const_bitmap_t), bitmap1, bitmap2)
end

function hwloc_bitmap_compare(bitmap1, bitmap2)
    ccall((:hwloc_bitmap_compare, libhwloc), Cint, (hwloc_const_bitmap_t, hwloc_const_bitmap_t), bitmap1, bitmap2)
end

function hwloc_get_api_version()
    ccall((:hwloc_get_api_version, libhwloc), Cuint, ())
end

const hwloc_cpuset_t = hwloc_bitmap_t

const hwloc_const_cpuset_t = hwloc_const_bitmap_t

const hwloc_nodeset_t = hwloc_bitmap_t

const hwloc_const_nodeset_t = hwloc_const_bitmap_t

@cenum hwloc_obj_type_t::UInt32 begin
    HWLOC_OBJ_MACHINE = 0
    HWLOC_OBJ_PACKAGE = 1
    HWLOC_OBJ_CORE = 2
    HWLOC_OBJ_PU = 3
    HWLOC_OBJ_L1CACHE = 4
    HWLOC_OBJ_L2CACHE = 5
    HWLOC_OBJ_L3CACHE = 6
    HWLOC_OBJ_L4CACHE = 7
    HWLOC_OBJ_L5CACHE = 8
    HWLOC_OBJ_L1ICACHE = 9
    HWLOC_OBJ_L2ICACHE = 10
    HWLOC_OBJ_L3ICACHE = 11
    HWLOC_OBJ_GROUP = 12
    HWLOC_OBJ_NUMANODE = 13
    HWLOC_OBJ_BRIDGE = 14
    HWLOC_OBJ_PCI_DEVICE = 15
    HWLOC_OBJ_OS_DEVICE = 16
    HWLOC_OBJ_MISC = 17
    HWLOC_OBJ_MEMCACHE = 18
    HWLOC_OBJ_DIE = 19
    HWLOC_OBJ_TYPE_MAX = 20
end

@cenum hwloc_obj_cache_type_e::UInt32 begin
    HWLOC_OBJ_CACHE_UNIFIED = 0
    HWLOC_OBJ_CACHE_DATA = 1
    HWLOC_OBJ_CACHE_INSTRUCTION = 2
end

const hwloc_obj_cache_type_t = hwloc_obj_cache_type_e

@cenum hwloc_obj_bridge_type_e::UInt32 begin
    HWLOC_OBJ_BRIDGE_HOST = 0
    HWLOC_OBJ_BRIDGE_PCI = 1
end

const hwloc_obj_bridge_type_t = hwloc_obj_bridge_type_e

@cenum hwloc_obj_osdev_type_e::UInt32 begin
    HWLOC_OBJ_OSDEV_BLOCK = 0
    HWLOC_OBJ_OSDEV_GPU = 1
    HWLOC_OBJ_OSDEV_NETWORK = 2
    HWLOC_OBJ_OSDEV_OPENFABRICS = 3
    HWLOC_OBJ_OSDEV_DMA = 4
    HWLOC_OBJ_OSDEV_COPROC = 5
end

const hwloc_obj_osdev_type_t = hwloc_obj_osdev_type_e

function hwloc_compare_types(type1, type2)
    ccall((:hwloc_compare_types, libhwloc), Cint, (hwloc_obj_type_t, hwloc_obj_type_t), type1, type2)
end

struct hwloc_obj_attr_u
    data::NTuple{40, UInt8}
end

function Base.getproperty(x::Ptr{hwloc_obj_attr_u}, f::Symbol)
    f === :numanode && return Ptr{hwloc_numanode_attr_s}(x + 0)
    f === :cache && return Ptr{hwloc_cache_attr_s}(x + 0)
    f === :group && return Ptr{hwloc_group_attr_s}(x + 0)
    f === :pcidev && return Ptr{hwloc_pcidev_attr_s}(x + 0)
    f === :bridge && return Ptr{hwloc_bridge_attr_s}(x + 0)
    f === :osdev && return Ptr{hwloc_osdev_attr_s}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::hwloc_obj_attr_u, f::Symbol)
    r = Ref{hwloc_obj_attr_u}(x)
    ptr = Base.unsafe_convert(Ptr{hwloc_obj_attr_u}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{hwloc_obj_attr_u}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct hwloc_info_s
    name::Ptr{Cchar}
    value::Ptr{Cchar}
end

struct hwloc_obj
    type::hwloc_obj_type_t
    subtype::Ptr{Cchar}
    os_index::Cuint
    name::Ptr{Cchar}
    total_memory::hwloc_uint64_t
    attr::Ptr{hwloc_obj_attr_u}
    depth::Cint
    logical_index::Cuint
    next_cousin::Ptr{hwloc_obj}
    prev_cousin::Ptr{hwloc_obj}
    parent::Ptr{hwloc_obj}
    sibling_rank::Cuint
    next_sibling::Ptr{hwloc_obj}
    prev_sibling::Ptr{hwloc_obj}
    arity::Cuint
    children::Ptr{Ptr{hwloc_obj}}
    first_child::Ptr{hwloc_obj}
    last_child::Ptr{hwloc_obj}
    symmetric_subtree::Cint
    memory_arity::Cuint
    memory_first_child::Ptr{hwloc_obj}
    io_arity::Cuint
    io_first_child::Ptr{hwloc_obj}
    misc_arity::Cuint
    misc_first_child::Ptr{hwloc_obj}
    cpuset::hwloc_cpuset_t
    complete_cpuset::hwloc_cpuset_t
    nodeset::hwloc_nodeset_t
    complete_nodeset::hwloc_nodeset_t
    infos::Ptr{hwloc_info_s}
    infos_count::Cuint
    userdata::Ptr{Cvoid}
    gp_index::hwloc_uint64_t
end

const hwloc_obj_t = Ptr{hwloc_obj}

mutable struct hwloc_topology end

const hwloc_topology_t = Ptr{hwloc_topology}

function hwloc_topology_init(topologyp)
    ccall((:hwloc_topology_init, libhwloc), Cint, (Ptr{hwloc_topology_t},), topologyp)
end

function hwloc_topology_load(topology)
    ccall((:hwloc_topology_load, libhwloc), Cint, (hwloc_topology_t,), topology)
end

function hwloc_topology_destroy(topology)
    ccall((:hwloc_topology_destroy, libhwloc), Cvoid, (hwloc_topology_t,), topology)
end

function hwloc_topology_dup(newtopology, oldtopology)
    ccall((:hwloc_topology_dup, libhwloc), Cint, (Ptr{hwloc_topology_t}, hwloc_topology_t), newtopology, oldtopology)
end

function hwloc_topology_abi_check(topology)
    ccall((:hwloc_topology_abi_check, libhwloc), Cint, (hwloc_topology_t,), topology)
end

function hwloc_topology_check(topology)
    ccall((:hwloc_topology_check, libhwloc), Cvoid, (hwloc_topology_t,), topology)
end

function hwloc_topology_get_depth(topology)
    ccall((:hwloc_topology_get_depth, libhwloc), Cint, (hwloc_topology_t,), topology)
end

function hwloc_get_type_depth(topology, type)
    ccall((:hwloc_get_type_depth, libhwloc), Cint, (hwloc_topology_t, hwloc_obj_type_t), topology, type)
end

@cenum hwloc_get_type_depth_e::Int32 begin
    HWLOC_TYPE_DEPTH_UNKNOWN = -1
    HWLOC_TYPE_DEPTH_MULTIPLE = -2
    HWLOC_TYPE_DEPTH_NUMANODE = -3
    HWLOC_TYPE_DEPTH_BRIDGE = -4
    HWLOC_TYPE_DEPTH_PCI_DEVICE = -5
    HWLOC_TYPE_DEPTH_OS_DEVICE = -6
    HWLOC_TYPE_DEPTH_MISC = -7
    HWLOC_TYPE_DEPTH_MEMCACHE = -8
end

function hwloc_get_memory_parents_depth(topology)
    ccall((:hwloc_get_memory_parents_depth, libhwloc), Cint, (hwloc_topology_t,), topology)
end

function hwloc_get_type_or_below_depth(topology, type)
    ccall((:hwloc_get_type_or_below_depth, libhwloc), Cint, (hwloc_topology_t, hwloc_obj_type_t), topology, type)
end

function hwloc_get_type_or_above_depth(topology, type)
    ccall((:hwloc_get_type_or_above_depth, libhwloc), Cint, (hwloc_topology_t, hwloc_obj_type_t), topology, type)
end

function hwloc_get_depth_type(topology, depth)
    ccall((:hwloc_get_depth_type, libhwloc), hwloc_obj_type_t, (hwloc_topology_t, Cint), topology, depth)
end

function hwloc_get_nbobjs_by_depth(topology, depth)
    ccall((:hwloc_get_nbobjs_by_depth, libhwloc), Cuint, (hwloc_topology_t, Cint), topology, depth)
end

function hwloc_get_nbobjs_by_type(topology, type)
    ccall((:hwloc_get_nbobjs_by_type, libhwloc), Cint, (hwloc_topology_t, hwloc_obj_type_t), topology, type)
end

function hwloc_get_root_obj(topology)
    ccall((:hwloc_get_root_obj, libhwloc), hwloc_obj_t, (hwloc_topology_t,), topology)
end

function hwloc_get_obj_by_depth(topology, depth, idx)
    ccall((:hwloc_get_obj_by_depth, libhwloc), hwloc_obj_t, (hwloc_topology_t, Cint, Cuint), topology, depth, idx)
end

function hwloc_get_obj_by_type(topology, type, idx)
    ccall((:hwloc_get_obj_by_type, libhwloc), hwloc_obj_t, (hwloc_topology_t, hwloc_obj_type_t, Cuint), topology, type, idx)
end

function hwloc_get_next_obj_by_depth(topology, depth, prev)
    ccall((:hwloc_get_next_obj_by_depth, libhwloc), hwloc_obj_t, (hwloc_topology_t, Cint, hwloc_obj_t), topology, depth, prev)
end

function hwloc_get_next_obj_by_type(topology, type, prev)
    ccall((:hwloc_get_next_obj_by_type, libhwloc), hwloc_obj_t, (hwloc_topology_t, hwloc_obj_type_t, hwloc_obj_t), topology, type, prev)
end

function hwloc_obj_type_string(type)
    ccall((:hwloc_obj_type_string, libhwloc), Ptr{Cchar}, (hwloc_obj_type_t,), type)
end

function hwloc_obj_type_snprintf(string, size, obj, verbose)
    ccall((:hwloc_obj_type_snprintf, libhwloc), Cint, (Ptr{Cchar}, Csize_t, hwloc_obj_t, Cint), string, size, obj, verbose)
end

function hwloc_obj_attr_snprintf(string, size, obj, separator, verbose)
    ccall((:hwloc_obj_attr_snprintf, libhwloc), Cint, (Ptr{Cchar}, Csize_t, hwloc_obj_t, Ptr{Cchar}, Cint), string, size, obj, separator, verbose)
end

function hwloc_type_sscanf(string, typep, attrp, attrsize)
    ccall((:hwloc_type_sscanf, libhwloc), Cint, (Ptr{Cchar}, Ptr{hwloc_obj_type_t}, Ptr{hwloc_obj_attr_u}, Csize_t), string, typep, attrp, attrsize)
end

function hwloc_type_sscanf_as_depth(string, typep, topology, depthp)
    ccall((:hwloc_type_sscanf_as_depth, libhwloc), Cint, (Ptr{Cchar}, Ptr{hwloc_obj_type_t}, hwloc_topology_t, Ptr{Cint}), string, typep, topology, depthp)
end

function hwloc_obj_get_info_by_name(obj, name)
    ccall((:hwloc_obj_get_info_by_name, libhwloc), Ptr{Cchar}, (hwloc_obj_t, Ptr{Cchar}), obj, name)
end

function hwloc_obj_add_info(obj, name, value)
    ccall((:hwloc_obj_add_info, libhwloc), Cint, (hwloc_obj_t, Ptr{Cchar}, Ptr{Cchar}), obj, name, value)
end

@cenum hwloc_cpubind_flags_t::UInt32 begin
    HWLOC_CPUBIND_PROCESS = 1
    HWLOC_CPUBIND_THREAD = 2
    HWLOC_CPUBIND_STRICT = 4
    HWLOC_CPUBIND_NOMEMBIND = 8
end

function hwloc_set_cpubind(topology, set, flags)
    ccall((:hwloc_set_cpubind, libhwloc), Cint, (hwloc_topology_t, hwloc_const_cpuset_t, Cint), topology, set, flags)
end

function hwloc_get_cpubind(topology, set, flags)
    ccall((:hwloc_get_cpubind, libhwloc), Cint, (hwloc_topology_t, hwloc_cpuset_t, Cint), topology, set, flags)
end

function hwloc_set_proc_cpubind(topology, pid, set, flags)
    ccall((:hwloc_set_proc_cpubind, libhwloc), Cint, (hwloc_topology_t, pid_t, hwloc_const_cpuset_t, Cint), topology, pid, set, flags)
end

function hwloc_get_proc_cpubind(topology, pid, set, flags)
    ccall((:hwloc_get_proc_cpubind, libhwloc), Cint, (hwloc_topology_t, pid_t, hwloc_cpuset_t, Cint), topology, pid, set, flags)
end

function hwloc_set_thread_cpubind(topology, thread, set, flags)
    ccall((:hwloc_set_thread_cpubind, libhwloc), Cint, (hwloc_topology_t, pthread_t, hwloc_const_cpuset_t, Cint), topology, thread, set, flags)
end

function hwloc_get_thread_cpubind(topology, thread, set, flags)
    ccall((:hwloc_get_thread_cpubind, libhwloc), Cint, (hwloc_topology_t, pthread_t, hwloc_cpuset_t, Cint), topology, thread, set, flags)
end

function hwloc_get_last_cpu_location(topology, set, flags)
    ccall((:hwloc_get_last_cpu_location, libhwloc), Cint, (hwloc_topology_t, hwloc_cpuset_t, Cint), topology, set, flags)
end

function hwloc_get_proc_last_cpu_location(topology, pid, set, flags)
    ccall((:hwloc_get_proc_last_cpu_location, libhwloc), Cint, (hwloc_topology_t, pid_t, hwloc_cpuset_t, Cint), topology, pid, set, flags)
end

@cenum hwloc_membind_policy_t::Int32 begin
    HWLOC_MEMBIND_DEFAULT = 0
    HWLOC_MEMBIND_FIRSTTOUCH = 1
    HWLOC_MEMBIND_BIND = 2
    HWLOC_MEMBIND_INTERLEAVE = 3
    HWLOC_MEMBIND_NEXTTOUCH = 4
    HWLOC_MEMBIND_MIXED = -1
end

@cenum hwloc_membind_flags_t::UInt32 begin
    HWLOC_MEMBIND_PROCESS = 1
    HWLOC_MEMBIND_THREAD = 2
    HWLOC_MEMBIND_STRICT = 4
    HWLOC_MEMBIND_MIGRATE = 8
    HWLOC_MEMBIND_NOCPUBIND = 16
    HWLOC_MEMBIND_BYNODESET = 32
end

function hwloc_set_membind(topology, set, policy, flags)
    ccall((:hwloc_set_membind, libhwloc), Cint, (hwloc_topology_t, hwloc_const_bitmap_t, hwloc_membind_policy_t, Cint), topology, set, policy, flags)
end

function hwloc_get_membind(topology, set, policy, flags)
    ccall((:hwloc_get_membind, libhwloc), Cint, (hwloc_topology_t, hwloc_bitmap_t, Ptr{hwloc_membind_policy_t}, Cint), topology, set, policy, flags)
end

function hwloc_set_proc_membind(topology, pid, set, policy, flags)
    ccall((:hwloc_set_proc_membind, libhwloc), Cint, (hwloc_topology_t, pid_t, hwloc_const_bitmap_t, hwloc_membind_policy_t, Cint), topology, pid, set, policy, flags)
end

function hwloc_get_proc_membind(topology, pid, set, policy, flags)
    ccall((:hwloc_get_proc_membind, libhwloc), Cint, (hwloc_topology_t, pid_t, hwloc_bitmap_t, Ptr{hwloc_membind_policy_t}, Cint), topology, pid, set, policy, flags)
end

function hwloc_set_area_membind(topology, addr, len, set, policy, flags)
    ccall((:hwloc_set_area_membind, libhwloc), Cint, (hwloc_topology_t, Ptr{Cvoid}, Csize_t, hwloc_const_bitmap_t, hwloc_membind_policy_t, Cint), topology, addr, len, set, policy, flags)
end

function hwloc_get_area_membind(topology, addr, len, set, policy, flags)
    ccall((:hwloc_get_area_membind, libhwloc), Cint, (hwloc_topology_t, Ptr{Cvoid}, Csize_t, hwloc_bitmap_t, Ptr{hwloc_membind_policy_t}, Cint), topology, addr, len, set, policy, flags)
end

function hwloc_get_area_memlocation(topology, addr, len, set, flags)
    ccall((:hwloc_get_area_memlocation, libhwloc), Cint, (hwloc_topology_t, Ptr{Cvoid}, Csize_t, hwloc_bitmap_t, Cint), topology, addr, len, set, flags)
end

function hwloc_alloc(topology, len)
    ccall((:hwloc_alloc, libhwloc), Ptr{Cvoid}, (hwloc_topology_t, Csize_t), topology, len)
end

function hwloc_alloc_membind(topology, len, set, policy, flags)
    ccall((:hwloc_alloc_membind, libhwloc), Ptr{Cvoid}, (hwloc_topology_t, Csize_t, hwloc_const_bitmap_t, hwloc_membind_policy_t, Cint), topology, len, set, policy, flags)
end

function hwloc_alloc_membind_policy(topology, len, set, policy, flags)
    ccall((:hwloc_alloc_membind_policy, libhwloc), Ptr{Cvoid}, (hwloc_topology_t, Csize_t, hwloc_const_bitmap_t, hwloc_membind_policy_t, Cint), topology, len, set, policy, flags)
end

function hwloc_free(topology, addr, len)
    ccall((:hwloc_free, libhwloc), Cint, (hwloc_topology_t, Ptr{Cvoid}, Csize_t), topology, addr, len)
end

function hwloc_topology_set_pid(topology, pid)
    ccall((:hwloc_topology_set_pid, libhwloc), Cint, (hwloc_topology_t, pid_t), topology, pid)
end

function hwloc_topology_set_synthetic(topology, description)
    ccall((:hwloc_topology_set_synthetic, libhwloc), Cint, (hwloc_topology_t, Ptr{Cchar}), topology, description)
end

function hwloc_topology_set_xml(topology, xmlpath)
    ccall((:hwloc_topology_set_xml, libhwloc), Cint, (hwloc_topology_t, Ptr{Cchar}), topology, xmlpath)
end

function hwloc_topology_set_xmlbuffer(topology, buffer, size)
    ccall((:hwloc_topology_set_xmlbuffer, libhwloc), Cint, (hwloc_topology_t, Ptr{Cchar}, Cint), topology, buffer, size)
end

@cenum hwloc_topology_components_flag_e::UInt32 begin
    HWLOC_TOPOLOGY_COMPONENTS_FLAG_BLACKLIST = 1
end

function hwloc_topology_set_components(topology, flags, name)
    ccall((:hwloc_topology_set_components, libhwloc), Cint, (hwloc_topology_t, Culong, Ptr{Cchar}), topology, flags, name)
end

@cenum hwloc_topology_flags_e::UInt32 begin
    HWLOC_TOPOLOGY_FLAG_INCLUDE_DISALLOWED = 1
    HWLOC_TOPOLOGY_FLAG_IS_THISSYSTEM = 2
    HWLOC_TOPOLOGY_FLAG_THISSYSTEM_ALLOWED_RESOURCES = 4
    HWLOC_TOPOLOGY_FLAG_IMPORT_SUPPORT = 8
    HWLOC_TOPOLOGY_FLAG_RESTRICT_TO_CPUBINDING = 16
    HWLOC_TOPOLOGY_FLAG_RESTRICT_TO_MEMBINDING = 32
    HWLOC_TOPOLOGY_FLAG_DONT_CHANGE_BINDING = 64
    HWLOC_TOPOLOGY_FLAG_NO_DISTANCES = 128
    HWLOC_TOPOLOGY_FLAG_NO_MEMATTRS = 256
    HWLOC_TOPOLOGY_FLAG_NO_CPUKINDS = 512
end

function hwloc_topology_set_flags(topology, flags)
    ccall((:hwloc_topology_set_flags, libhwloc), Cint, (hwloc_topology_t, Culong), topology, flags)
end

function hwloc_topology_get_flags(topology)
    ccall((:hwloc_topology_get_flags, libhwloc), Culong, (hwloc_topology_t,), topology)
end

function hwloc_topology_is_thissystem(topology)
    ccall((:hwloc_topology_is_thissystem, libhwloc), Cint, (hwloc_topology_t,), topology)
end

struct hwloc_topology_discovery_support
    pu::Cuchar
    numa::Cuchar
    numa_memory::Cuchar
    disallowed_pu::Cuchar
    disallowed_numa::Cuchar
    cpukind_efficiency::Cuchar
end

struct hwloc_topology_cpubind_support
    set_thisproc_cpubind::Cuchar
    get_thisproc_cpubind::Cuchar
    set_proc_cpubind::Cuchar
    get_proc_cpubind::Cuchar
    set_thisthread_cpubind::Cuchar
    get_thisthread_cpubind::Cuchar
    set_thread_cpubind::Cuchar
    get_thread_cpubind::Cuchar
    get_thisproc_last_cpu_location::Cuchar
    get_proc_last_cpu_location::Cuchar
    get_thisthread_last_cpu_location::Cuchar
end

struct hwloc_topology_membind_support
    set_thisproc_membind::Cuchar
    get_thisproc_membind::Cuchar
    set_proc_membind::Cuchar
    get_proc_membind::Cuchar
    set_thisthread_membind::Cuchar
    get_thisthread_membind::Cuchar
    set_area_membind::Cuchar
    get_area_membind::Cuchar
    alloc_membind::Cuchar
    firsttouch_membind::Cuchar
    bind_membind::Cuchar
    interleave_membind::Cuchar
    nexttouch_membind::Cuchar
    migrate_membind::Cuchar
    get_area_memlocation::Cuchar
end

struct hwloc_topology_misc_support
    imported_support::Cuchar
end

struct hwloc_topology_support
    discovery::Ptr{hwloc_topology_discovery_support}
    cpubind::Ptr{hwloc_topology_cpubind_support}
    membind::Ptr{hwloc_topology_membind_support}
    misc::Ptr{hwloc_topology_misc_support}
end

function hwloc_topology_get_support(topology)
    ccall((:hwloc_topology_get_support, libhwloc), Ptr{hwloc_topology_support}, (hwloc_topology_t,), topology)
end

@cenum hwloc_type_filter_e::UInt32 begin
    HWLOC_TYPE_FILTER_KEEP_ALL = 0
    HWLOC_TYPE_FILTER_KEEP_NONE = 1
    HWLOC_TYPE_FILTER_KEEP_STRUCTURE = 2
    HWLOC_TYPE_FILTER_KEEP_IMPORTANT = 3
end

function hwloc_topology_set_type_filter(topology, type, filter)
    ccall((:hwloc_topology_set_type_filter, libhwloc), Cint, (hwloc_topology_t, hwloc_obj_type_t, hwloc_type_filter_e), topology, type, filter)
end

function hwloc_topology_get_type_filter(topology, type, filter)
    ccall((:hwloc_topology_get_type_filter, libhwloc), Cint, (hwloc_topology_t, hwloc_obj_type_t, Ptr{hwloc_type_filter_e}), topology, type, filter)
end

function hwloc_topology_set_all_types_filter(topology, filter)
    ccall((:hwloc_topology_set_all_types_filter, libhwloc), Cint, (hwloc_topology_t, hwloc_type_filter_e), topology, filter)
end

function hwloc_topology_set_cache_types_filter(topology, filter)
    ccall((:hwloc_topology_set_cache_types_filter, libhwloc), Cint, (hwloc_topology_t, hwloc_type_filter_e), topology, filter)
end

function hwloc_topology_set_icache_types_filter(topology, filter)
    ccall((:hwloc_topology_set_icache_types_filter, libhwloc), Cint, (hwloc_topology_t, hwloc_type_filter_e), topology, filter)
end

function hwloc_topology_set_io_types_filter(topology, filter)
    ccall((:hwloc_topology_set_io_types_filter, libhwloc), Cint, (hwloc_topology_t, hwloc_type_filter_e), topology, filter)
end

function hwloc_topology_set_userdata(topology, userdata)
    ccall((:hwloc_topology_set_userdata, libhwloc), Cvoid, (hwloc_topology_t, Ptr{Cvoid}), topology, userdata)
end

function hwloc_topology_get_userdata(topology)
    ccall((:hwloc_topology_get_userdata, libhwloc), Ptr{Cvoid}, (hwloc_topology_t,), topology)
end

@cenum hwloc_restrict_flags_e::UInt32 begin
    HWLOC_RESTRICT_FLAG_REMOVE_CPULESS = 1
    HWLOC_RESTRICT_FLAG_BYNODESET = 8
    HWLOC_RESTRICT_FLAG_REMOVE_MEMLESS = 16
    HWLOC_RESTRICT_FLAG_ADAPT_MISC = 2
    HWLOC_RESTRICT_FLAG_ADAPT_IO = 4
end

function hwloc_topology_restrict(topology, set, flags)
    ccall((:hwloc_topology_restrict, libhwloc), Cint, (hwloc_topology_t, hwloc_const_bitmap_t, Culong), topology, set, flags)
end

@cenum hwloc_allow_flags_e::UInt32 begin
    HWLOC_ALLOW_FLAG_ALL = 1
    HWLOC_ALLOW_FLAG_LOCAL_RESTRICTIONS = 2
    HWLOC_ALLOW_FLAG_CUSTOM = 4
end

function hwloc_topology_allow(topology, cpuset, nodeset, flags)
    ccall((:hwloc_topology_allow, libhwloc), Cint, (hwloc_topology_t, hwloc_const_cpuset_t, hwloc_const_nodeset_t, Culong), topology, cpuset, nodeset, flags)
end

function hwloc_topology_insert_misc_object(topology, parent, name)
    ccall((:hwloc_topology_insert_misc_object, libhwloc), hwloc_obj_t, (hwloc_topology_t, hwloc_obj_t, Ptr{Cchar}), topology, parent, name)
end

function hwloc_topology_alloc_group_object(topology)
    ccall((:hwloc_topology_alloc_group_object, libhwloc), hwloc_obj_t, (hwloc_topology_t,), topology)
end

function hwloc_topology_insert_group_object(topology, group)
    ccall((:hwloc_topology_insert_group_object, libhwloc), hwloc_obj_t, (hwloc_topology_t, hwloc_obj_t), topology, group)
end

function hwloc_obj_add_other_obj_sets(dst, src)
    ccall((:hwloc_obj_add_other_obj_sets, libhwloc), Cint, (hwloc_obj_t, hwloc_obj_t), dst, src)
end

function hwloc_topology_refresh(topology)
    ccall((:hwloc_topology_refresh, libhwloc), Cint, (hwloc_topology_t,), topology)
end

function hwloc_get_first_largest_obj_inside_cpuset(topology, set)
    ccall((:hwloc_get_first_largest_obj_inside_cpuset, libhwloc), hwloc_obj_t, (hwloc_topology_t, hwloc_const_cpuset_t), topology, set)
end

function hwloc_get_largest_objs_inside_cpuset(topology, set, objs, max)
    ccall((:hwloc_get_largest_objs_inside_cpuset, libhwloc), Cint, (hwloc_topology_t, hwloc_const_cpuset_t, Ptr{hwloc_obj_t}, Cint), topology, set, objs, max)
end

function hwloc_get_next_obj_inside_cpuset_by_depth(topology, set, depth, prev)
    ccall((:hwloc_get_next_obj_inside_cpuset_by_depth, libhwloc), hwloc_obj_t, (hwloc_topology_t, hwloc_const_cpuset_t, Cint, hwloc_obj_t), topology, set, depth, prev)
end

function hwloc_get_next_obj_inside_cpuset_by_type(topology, set, type, prev)
    ccall((:hwloc_get_next_obj_inside_cpuset_by_type, libhwloc), hwloc_obj_t, (hwloc_topology_t, hwloc_const_cpuset_t, hwloc_obj_type_t, hwloc_obj_t), topology, set, type, prev)
end

function hwloc_get_obj_inside_cpuset_by_depth(topology, set, depth, idx)
    ccall((:hwloc_get_obj_inside_cpuset_by_depth, libhwloc), hwloc_obj_t, (hwloc_topology_t, hwloc_const_cpuset_t, Cint, Cuint), topology, set, depth, idx)
end

function hwloc_get_obj_inside_cpuset_by_type(topology, set, type, idx)
    ccall((:hwloc_get_obj_inside_cpuset_by_type, libhwloc), hwloc_obj_t, (hwloc_topology_t, hwloc_const_cpuset_t, hwloc_obj_type_t, Cuint), topology, set, type, idx)
end

function hwloc_get_nbobjs_inside_cpuset_by_depth(topology, set, depth)
    ccall((:hwloc_get_nbobjs_inside_cpuset_by_depth, libhwloc), Cuint, (hwloc_topology_t, hwloc_const_cpuset_t, Cint), topology, set, depth)
end

function hwloc_get_nbobjs_inside_cpuset_by_type(topology, set, type)
    ccall((:hwloc_get_nbobjs_inside_cpuset_by_type, libhwloc), Cint, (hwloc_topology_t, hwloc_const_cpuset_t, hwloc_obj_type_t), topology, set, type)
end

function hwloc_get_obj_index_inside_cpuset(topology, set, obj)
    ccall((:hwloc_get_obj_index_inside_cpuset, libhwloc), Cint, (hwloc_topology_t, hwloc_const_cpuset_t, hwloc_obj_t), topology, set, obj)
end

function hwloc_get_child_covering_cpuset(topology, set, parent)
    ccall((:hwloc_get_child_covering_cpuset, libhwloc), hwloc_obj_t, (hwloc_topology_t, hwloc_const_cpuset_t, hwloc_obj_t), topology, set, parent)
end

function hwloc_get_obj_covering_cpuset(topology, set)
    ccall((:hwloc_get_obj_covering_cpuset, libhwloc), hwloc_obj_t, (hwloc_topology_t, hwloc_const_cpuset_t), topology, set)
end

function hwloc_get_next_obj_covering_cpuset_by_depth(topology, set, depth, prev)
    ccall((:hwloc_get_next_obj_covering_cpuset_by_depth, libhwloc), hwloc_obj_t, (hwloc_topology_t, hwloc_const_cpuset_t, Cint, hwloc_obj_t), topology, set, depth, prev)
end

function hwloc_get_next_obj_covering_cpuset_by_type(topology, set, type, prev)
    ccall((:hwloc_get_next_obj_covering_cpuset_by_type, libhwloc), hwloc_obj_t, (hwloc_topology_t, hwloc_const_cpuset_t, hwloc_obj_type_t, hwloc_obj_t), topology, set, type, prev)
end

function hwloc_get_ancestor_obj_by_depth(topology, depth, obj)
    ccall((:hwloc_get_ancestor_obj_by_depth, libhwloc), hwloc_obj_t, (hwloc_topology_t, Cint, hwloc_obj_t), topology, depth, obj)
end

function hwloc_get_ancestor_obj_by_type(topology, type, obj)
    ccall((:hwloc_get_ancestor_obj_by_type, libhwloc), hwloc_obj_t, (hwloc_topology_t, hwloc_obj_type_t, hwloc_obj_t), topology, type, obj)
end

function hwloc_get_common_ancestor_obj(topology, obj1, obj2)
    ccall((:hwloc_get_common_ancestor_obj, libhwloc), hwloc_obj_t, (hwloc_topology_t, hwloc_obj_t, hwloc_obj_t), topology, obj1, obj2)
end

function hwloc_obj_is_in_subtree(topology, obj, subtree_root)
    ccall((:hwloc_obj_is_in_subtree, libhwloc), Cint, (hwloc_topology_t, hwloc_obj_t, hwloc_obj_t), topology, obj, subtree_root)
end

function hwloc_get_next_child(topology, parent, prev)
    ccall((:hwloc_get_next_child, libhwloc), hwloc_obj_t, (hwloc_topology_t, hwloc_obj_t, hwloc_obj_t), topology, parent, prev)
end

function hwloc_obj_type_is_normal(type)
    ccall((:hwloc_obj_type_is_normal, libhwloc), Cint, (hwloc_obj_type_t,), type)
end

function hwloc_obj_type_is_io(type)
    ccall((:hwloc_obj_type_is_io, libhwloc), Cint, (hwloc_obj_type_t,), type)
end

function hwloc_obj_type_is_memory(type)
    ccall((:hwloc_obj_type_is_memory, libhwloc), Cint, (hwloc_obj_type_t,), type)
end

function hwloc_obj_type_is_cache(type)
    ccall((:hwloc_obj_type_is_cache, libhwloc), Cint, (hwloc_obj_type_t,), type)
end

function hwloc_obj_type_is_dcache(type)
    ccall((:hwloc_obj_type_is_dcache, libhwloc), Cint, (hwloc_obj_type_t,), type)
end

function hwloc_obj_type_is_icache(type)
    ccall((:hwloc_obj_type_is_icache, libhwloc), Cint, (hwloc_obj_type_t,), type)
end

function hwloc_get_cache_type_depth(topology, cachelevel, cachetype)
    ccall((:hwloc_get_cache_type_depth, libhwloc), Cint, (hwloc_topology_t, Cuint, hwloc_obj_cache_type_t), topology, cachelevel, cachetype)
end

function hwloc_get_cache_covering_cpuset(topology, set)
    ccall((:hwloc_get_cache_covering_cpuset, libhwloc), hwloc_obj_t, (hwloc_topology_t, hwloc_const_cpuset_t), topology, set)
end

function hwloc_get_shared_cache_covering_obj(topology, obj)
    ccall((:hwloc_get_shared_cache_covering_obj, libhwloc), hwloc_obj_t, (hwloc_topology_t, hwloc_obj_t), topology, obj)
end

function hwloc_bitmap_singlify_per_core(topology, cpuset, which)
    ccall((:hwloc_bitmap_singlify_per_core, libhwloc), Cint, (hwloc_topology_t, hwloc_bitmap_t, Cuint), topology, cpuset, which)
end

function hwloc_get_pu_obj_by_os_index(topology, os_index)
    ccall((:hwloc_get_pu_obj_by_os_index, libhwloc), hwloc_obj_t, (hwloc_topology_t, Cuint), topology, os_index)
end

function hwloc_get_numanode_obj_by_os_index(topology, os_index)
    ccall((:hwloc_get_numanode_obj_by_os_index, libhwloc), hwloc_obj_t, (hwloc_topology_t, Cuint), topology, os_index)
end

function hwloc_get_closest_objs(topology, src, objs, max)
    ccall((:hwloc_get_closest_objs, libhwloc), Cuint, (hwloc_topology_t, hwloc_obj_t, Ptr{hwloc_obj_t}, Cuint), topology, src, objs, max)
end

function hwloc_get_obj_below_by_type(topology, type1, idx1, type2, idx2)
    ccall((:hwloc_get_obj_below_by_type, libhwloc), hwloc_obj_t, (hwloc_topology_t, hwloc_obj_type_t, Cuint, hwloc_obj_type_t, Cuint), topology, type1, idx1, type2, idx2)
end

function hwloc_get_obj_below_array_by_type(topology, nr, typev, idxv)
    ccall((:hwloc_get_obj_below_array_by_type, libhwloc), hwloc_obj_t, (hwloc_topology_t, Cint, Ptr{hwloc_obj_type_t}, Ptr{Cuint}), topology, nr, typev, idxv)
end

function hwloc_get_obj_with_same_locality(topology, src, type, subtype, nameprefix, flags)
    ccall((:hwloc_get_obj_with_same_locality, libhwloc), hwloc_obj_t, (hwloc_topology_t, hwloc_obj_t, hwloc_obj_type_t, Ptr{Cchar}, Ptr{Cchar}, Culong), topology, src, type, subtype, nameprefix, flags)
end

@cenum hwloc_distrib_flags_e::UInt32 begin
    HWLOC_DISTRIB_FLAG_REVERSE = 1
end

function hwloc_distrib(topology, roots, n_roots, set, n, until, flags)
    ccall((:hwloc_distrib, libhwloc), Cint, (hwloc_topology_t, Ptr{hwloc_obj_t}, Cuint, Ptr{hwloc_cpuset_t}, Cuint, Cint, Culong), topology, roots, n_roots, set, n, until, flags)
end

function hwloc_topology_get_complete_cpuset(topology)
    ccall((:hwloc_topology_get_complete_cpuset, libhwloc), hwloc_const_cpuset_t, (hwloc_topology_t,), topology)
end

function hwloc_topology_get_topology_cpuset(topology)
    ccall((:hwloc_topology_get_topology_cpuset, libhwloc), hwloc_const_cpuset_t, (hwloc_topology_t,), topology)
end

function hwloc_topology_get_allowed_cpuset(topology)
    ccall((:hwloc_topology_get_allowed_cpuset, libhwloc), hwloc_const_cpuset_t, (hwloc_topology_t,), topology)
end

function hwloc_topology_get_complete_nodeset(topology)
    ccall((:hwloc_topology_get_complete_nodeset, libhwloc), hwloc_const_nodeset_t, (hwloc_topology_t,), topology)
end

function hwloc_topology_get_topology_nodeset(topology)
    ccall((:hwloc_topology_get_topology_nodeset, libhwloc), hwloc_const_nodeset_t, (hwloc_topology_t,), topology)
end

function hwloc_topology_get_allowed_nodeset(topology)
    ccall((:hwloc_topology_get_allowed_nodeset, libhwloc), hwloc_const_nodeset_t, (hwloc_topology_t,), topology)
end

function hwloc_cpuset_to_nodeset(topology, _cpuset, nodeset)
    ccall((:hwloc_cpuset_to_nodeset, libhwloc), Cint, (hwloc_topology_t, hwloc_const_cpuset_t, hwloc_nodeset_t), topology, _cpuset, nodeset)
end

function hwloc_cpuset_from_nodeset(topology, _cpuset, nodeset)
    ccall((:hwloc_cpuset_from_nodeset, libhwloc), Cint, (hwloc_topology_t, hwloc_cpuset_t, hwloc_const_nodeset_t), topology, _cpuset, nodeset)
end

function hwloc_get_non_io_ancestor_obj(topology, ioobj)
    ccall((:hwloc_get_non_io_ancestor_obj, libhwloc), hwloc_obj_t, (hwloc_topology_t, hwloc_obj_t), topology, ioobj)
end

function hwloc_get_next_pcidev(topology, prev)
    ccall((:hwloc_get_next_pcidev, libhwloc), hwloc_obj_t, (hwloc_topology_t, hwloc_obj_t), topology, prev)
end

function hwloc_get_pcidev_by_busid(topology, domain, bus, dev, func)
    ccall((:hwloc_get_pcidev_by_busid, libhwloc), hwloc_obj_t, (hwloc_topology_t, Cuint, Cuint, Cuint, Cuint), topology, domain, bus, dev, func)
end

function hwloc_get_pcidev_by_busidstring(topology, busid)
    ccall((:hwloc_get_pcidev_by_busidstring, libhwloc), hwloc_obj_t, (hwloc_topology_t, Ptr{Cchar}), topology, busid)
end

function hwloc_get_next_osdev(topology, prev)
    ccall((:hwloc_get_next_osdev, libhwloc), hwloc_obj_t, (hwloc_topology_t, hwloc_obj_t), topology, prev)
end

function hwloc_get_next_bridge(topology, prev)
    ccall((:hwloc_get_next_bridge, libhwloc), hwloc_obj_t, (hwloc_topology_t, hwloc_obj_t), topology, prev)
end

function hwloc_bridge_covers_pcibus(bridge, domain, bus)
    ccall((:hwloc_bridge_covers_pcibus, libhwloc), Cint, (hwloc_obj_t, Cuint, Cuint), bridge, domain, bus)
end

@cenum hwloc_memattr_id_e::UInt32 begin
    HWLOC_MEMATTR_ID_CAPACITY = 0
    HWLOC_MEMATTR_ID_LOCALITY = 1
    HWLOC_MEMATTR_ID_BANDWIDTH = 2
    HWLOC_MEMATTR_ID_READ_BANDWIDTH = 4
    HWLOC_MEMATTR_ID_WRITE_BANDWIDTH = 5
    HWLOC_MEMATTR_ID_LATENCY = 3
    HWLOC_MEMATTR_ID_READ_LATENCY = 6
    HWLOC_MEMATTR_ID_WRITE_LATENCY = 7
    HWLOC_MEMATTR_ID_MAX = 8
end

const hwloc_memattr_id_t = Cuint

function hwloc_memattr_get_by_name(topology, name, id)
    ccall((:hwloc_memattr_get_by_name, libhwloc), Cint, (hwloc_topology_t, Ptr{Cchar}, Ptr{hwloc_memattr_id_t}), topology, name, id)
end

@cenum hwloc_location_type_e::UInt32 begin
    HWLOC_LOCATION_TYPE_CPUSET = 1
    HWLOC_LOCATION_TYPE_OBJECT = 0
end

struct hwloc_location_u
    data::NTuple{8, UInt8}
end

function Base.getproperty(x::Ptr{hwloc_location_u}, f::Symbol)
    f === :cpuset && return Ptr{hwloc_cpuset_t}(x + 0)
    f === :object && return Ptr{hwloc_obj_t}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::hwloc_location_u, f::Symbol)
    r = Ref{hwloc_location_u}(x)
    ptr = Base.unsafe_convert(Ptr{hwloc_location_u}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{hwloc_location_u}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct hwloc_location
    data::NTuple{16, UInt8}
end

function Base.getproperty(x::Ptr{hwloc_location}, f::Symbol)
    f === :type && return Ptr{hwloc_location_type_e}(x + 0)
    f === :location && return Ptr{hwloc_location_u}(x + 8)
    return getfield(x, f)
end

function Base.getproperty(x::hwloc_location, f::Symbol)
    r = Ref{hwloc_location}(x)
    ptr = Base.unsafe_convert(Ptr{hwloc_location}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{hwloc_location}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

@cenum hwloc_local_numanode_flag_e::UInt32 begin
    HWLOC_LOCAL_NUMANODE_FLAG_LARGER_LOCALITY = 1
    HWLOC_LOCAL_NUMANODE_FLAG_SMALLER_LOCALITY = 2
    HWLOC_LOCAL_NUMANODE_FLAG_ALL = 4
end

function hwloc_get_local_numanode_objs(topology, location, nr, nodes, flags)
    ccall((:hwloc_get_local_numanode_objs, libhwloc), Cint, (hwloc_topology_t, Ptr{hwloc_location}, Ptr{Cuint}, Ptr{hwloc_obj_t}, Culong), topology, location, nr, nodes, flags)
end

function hwloc_memattr_get_value(topology, attribute, target_node, initiator, flags, value)
    ccall((:hwloc_memattr_get_value, libhwloc), Cint, (hwloc_topology_t, hwloc_memattr_id_t, hwloc_obj_t, Ptr{hwloc_location}, Culong, Ptr{hwloc_uint64_t}), topology, attribute, target_node, initiator, flags, value)
end

function hwloc_memattr_get_best_target(topology, attribute, initiator, flags, best_target, value)
    ccall((:hwloc_memattr_get_best_target, libhwloc), Cint, (hwloc_topology_t, hwloc_memattr_id_t, Ptr{hwloc_location}, Culong, Ptr{hwloc_obj_t}, Ptr{hwloc_uint64_t}), topology, attribute, initiator, flags, best_target, value)
end

function hwloc_memattr_get_best_initiator(topology, attribute, target, flags, best_initiator, value)
    ccall((:hwloc_memattr_get_best_initiator, libhwloc), Cint, (hwloc_topology_t, hwloc_memattr_id_t, hwloc_obj_t, Culong, Ptr{hwloc_location}, Ptr{hwloc_uint64_t}), topology, attribute, target, flags, best_initiator, value)
end

function hwloc_memattr_get_name(topology, attribute, name)
    ccall((:hwloc_memattr_get_name, libhwloc), Cint, (hwloc_topology_t, hwloc_memattr_id_t, Ptr{Ptr{Cchar}}), topology, attribute, name)
end

function hwloc_memattr_get_flags(topology, attribute, flags)
    ccall((:hwloc_memattr_get_flags, libhwloc), Cint, (hwloc_topology_t, hwloc_memattr_id_t, Ptr{Culong}), topology, attribute, flags)
end

@cenum hwloc_memattr_flag_e::UInt32 begin
    HWLOC_MEMATTR_FLAG_HIGHER_FIRST = 1
    HWLOC_MEMATTR_FLAG_LOWER_FIRST = 2
    HWLOC_MEMATTR_FLAG_NEED_INITIATOR = 4
end

function hwloc_memattr_register(topology, name, flags, id)
    ccall((:hwloc_memattr_register, libhwloc), Cint, (hwloc_topology_t, Ptr{Cchar}, Culong, Ptr{hwloc_memattr_id_t}), topology, name, flags, id)
end

function hwloc_memattr_set_value(topology, attribute, target_node, initiator, flags, value)
    ccall((:hwloc_memattr_set_value, libhwloc), Cint, (hwloc_topology_t, hwloc_memattr_id_t, hwloc_obj_t, Ptr{hwloc_location}, Culong, hwloc_uint64_t), topology, attribute, target_node, initiator, flags, value)
end

function hwloc_memattr_get_targets(topology, attribute, initiator, flags, nr, targets, values)
    ccall((:hwloc_memattr_get_targets, libhwloc), Cint, (hwloc_topology_t, hwloc_memattr_id_t, Ptr{hwloc_location}, Culong, Ptr{Cuint}, Ptr{hwloc_obj_t}, Ptr{hwloc_uint64_t}), topology, attribute, initiator, flags, nr, targets, values)
end

function hwloc_memattr_get_initiators(topology, attribute, target_node, flags, nr, initiators, values)
    ccall((:hwloc_memattr_get_initiators, libhwloc), Cint, (hwloc_topology_t, hwloc_memattr_id_t, hwloc_obj_t, Culong, Ptr{Cuint}, Ptr{hwloc_location}, Ptr{hwloc_uint64_t}), topology, attribute, target_node, flags, nr, initiators, values)
end

function hwloc_cpukinds_get_nr(topology, flags)
    ccall((:hwloc_cpukinds_get_nr, libhwloc), Cint, (hwloc_topology_t, Culong), topology, flags)
end

function hwloc_cpukinds_get_by_cpuset(topology, cpuset, flags)
    ccall((:hwloc_cpukinds_get_by_cpuset, libhwloc), Cint, (hwloc_topology_t, hwloc_const_bitmap_t, Culong), topology, cpuset, flags)
end

function hwloc_cpukinds_get_info(topology, kind_index, cpuset, efficiency, nr_infos, infos, flags)
    ccall((:hwloc_cpukinds_get_info, libhwloc), Cint, (hwloc_topology_t, Cuint, hwloc_bitmap_t, Ptr{Cint}, Ptr{Cuint}, Ptr{Ptr{hwloc_info_s}}, Culong), topology, kind_index, cpuset, efficiency, nr_infos, infos, flags)
end

function hwloc_cpukinds_register(topology, cpuset, forced_efficiency, nr_infos, infos, flags)
    ccall((:hwloc_cpukinds_register, libhwloc), Cint, (hwloc_topology_t, hwloc_bitmap_t, Cint, Cuint, Ptr{hwloc_info_s}, Culong), topology, cpuset, forced_efficiency, nr_infos, infos, flags)
end

@cenum hwloc_topology_export_xml_flags_e::UInt32 begin
    HWLOC_TOPOLOGY_EXPORT_XML_FLAG_V1 = 1
end

function hwloc_topology_export_xml(topology, xmlpath, flags)
    ccall((:hwloc_topology_export_xml, libhwloc), Cint, (hwloc_topology_t, Ptr{Cchar}, Culong), topology, xmlpath, flags)
end

function hwloc_topology_export_xmlbuffer(topology, xmlbuffer, buflen, flags)
    ccall((:hwloc_topology_export_xmlbuffer, libhwloc), Cint, (hwloc_topology_t, Ptr{Ptr{Cchar}}, Ptr{Cint}, Culong), topology, xmlbuffer, buflen, flags)
end

function hwloc_free_xmlbuffer(topology, xmlbuffer)
    ccall((:hwloc_free_xmlbuffer, libhwloc), Cvoid, (hwloc_topology_t, Ptr{Cchar}), topology, xmlbuffer)
end

function hwloc_topology_set_userdata_export_callback(topology, export_cb)
    ccall((:hwloc_topology_set_userdata_export_callback, libhwloc), Cvoid, (hwloc_topology_t, Ptr{Cvoid}), topology, export_cb)
end

function hwloc_export_obj_userdata(reserved, topology, obj, name, buffer, length)
    ccall((:hwloc_export_obj_userdata, libhwloc), Cint, (Ptr{Cvoid}, hwloc_topology_t, hwloc_obj_t, Ptr{Cchar}, Ptr{Cvoid}, Csize_t), reserved, topology, obj, name, buffer, length)
end

function hwloc_export_obj_userdata_base64(reserved, topology, obj, name, buffer, length)
    ccall((:hwloc_export_obj_userdata_base64, libhwloc), Cint, (Ptr{Cvoid}, hwloc_topology_t, hwloc_obj_t, Ptr{Cchar}, Ptr{Cvoid}, Csize_t), reserved, topology, obj, name, buffer, length)
end

function hwloc_topology_set_userdata_import_callback(topology, import_cb)
    ccall((:hwloc_topology_set_userdata_import_callback, libhwloc), Cvoid, (hwloc_topology_t, Ptr{Cvoid}), topology, import_cb)
end

@cenum hwloc_topology_export_synthetic_flags_e::UInt32 begin
    HWLOC_TOPOLOGY_EXPORT_SYNTHETIC_FLAG_NO_EXTENDED_TYPES = 1
    HWLOC_TOPOLOGY_EXPORT_SYNTHETIC_FLAG_NO_ATTRS = 2
    HWLOC_TOPOLOGY_EXPORT_SYNTHETIC_FLAG_V1 = 4
    HWLOC_TOPOLOGY_EXPORT_SYNTHETIC_FLAG_IGNORE_MEMORY = 8
end

function hwloc_topology_export_synthetic(topology, buffer, buflen, flags)
    ccall((:hwloc_topology_export_synthetic, libhwloc), Cint, (hwloc_topology_t, Ptr{Cchar}, Csize_t, Culong), topology, buffer, buflen, flags)
end

struct hwloc_distances_s
    nbobjs::Cuint
    objs::Ptr{hwloc_obj_t}
    kind::Culong
    values::Ptr{hwloc_uint64_t}
end

@cenum hwloc_distances_kind_e::UInt32 begin
    HWLOC_DISTANCES_KIND_FROM_OS = 1
    HWLOC_DISTANCES_KIND_FROM_USER = 2
    HWLOC_DISTANCES_KIND_MEANS_LATENCY = 4
    HWLOC_DISTANCES_KIND_MEANS_BANDWIDTH = 8
    HWLOC_DISTANCES_KIND_HETEROGENEOUS_TYPES = 16
end

function hwloc_distances_get(topology, nr, distances, kind, flags)
    ccall((:hwloc_distances_get, libhwloc), Cint, (hwloc_topology_t, Ptr{Cuint}, Ptr{Ptr{hwloc_distances_s}}, Culong, Culong), topology, nr, distances, kind, flags)
end

function hwloc_distances_get_by_depth(topology, depth, nr, distances, kind, flags)
    ccall((:hwloc_distances_get_by_depth, libhwloc), Cint, (hwloc_topology_t, Cint, Ptr{Cuint}, Ptr{Ptr{hwloc_distances_s}}, Culong, Culong), topology, depth, nr, distances, kind, flags)
end

function hwloc_distances_get_by_type(topology, type, nr, distances, kind, flags)
    ccall((:hwloc_distances_get_by_type, libhwloc), Cint, (hwloc_topology_t, hwloc_obj_type_t, Ptr{Cuint}, Ptr{Ptr{hwloc_distances_s}}, Culong, Culong), topology, type, nr, distances, kind, flags)
end

function hwloc_distances_get_by_name(topology, name, nr, distances, flags)
    ccall((:hwloc_distances_get_by_name, libhwloc), Cint, (hwloc_topology_t, Ptr{Cchar}, Ptr{Cuint}, Ptr{Ptr{hwloc_distances_s}}, Culong), topology, name, nr, distances, flags)
end

function hwloc_distances_get_name(topology, distances)
    ccall((:hwloc_distances_get_name, libhwloc), Ptr{Cchar}, (hwloc_topology_t, Ptr{hwloc_distances_s}), topology, distances)
end

function hwloc_distances_release(topology, distances)
    ccall((:hwloc_distances_release, libhwloc), Cvoid, (hwloc_topology_t, Ptr{hwloc_distances_s}), topology, distances)
end

@cenum hwloc_distances_transform_e::UInt32 begin
    HWLOC_DISTANCES_TRANSFORM_REMOVE_NULL = 0
    HWLOC_DISTANCES_TRANSFORM_LINKS = 1
    HWLOC_DISTANCES_TRANSFORM_MERGE_SWITCH_PORTS = 2
    HWLOC_DISTANCES_TRANSFORM_TRANSITIVE_CLOSURE = 3
end

function hwloc_distances_transform(topology, distances, transform, transform_attr, flags)
    ccall((:hwloc_distances_transform, libhwloc), Cint, (hwloc_topology_t, Ptr{hwloc_distances_s}, hwloc_distances_transform_e, Ptr{Cvoid}, Culong), topology, distances, transform, transform_attr, flags)
end

function hwloc_distances_obj_index(distances, obj)
    ccall((:hwloc_distances_obj_index, libhwloc), Cint, (Ptr{hwloc_distances_s}, hwloc_obj_t), distances, obj)
end

function hwloc_distances_obj_pair_values(distances, obj1, obj2, value1to2, value2to1)
    ccall((:hwloc_distances_obj_pair_values, libhwloc), Cint, (Ptr{hwloc_distances_s}, hwloc_obj_t, hwloc_obj_t, Ptr{hwloc_uint64_t}, Ptr{hwloc_uint64_t}), distances, obj1, obj2, value1to2, value2to1)
end

const hwloc_distances_add_handle_t = Ptr{Cvoid}

function hwloc_distances_add_create(topology, name, kind, flags)
    ccall((:hwloc_distances_add_create, libhwloc), hwloc_distances_add_handle_t, (hwloc_topology_t, Ptr{Cchar}, Culong, Culong), topology, name, kind, flags)
end

function hwloc_distances_add_values(topology, handle, nbobjs, objs, values, flags)
    ccall((:hwloc_distances_add_values, libhwloc), Cint, (hwloc_topology_t, hwloc_distances_add_handle_t, Cuint, Ptr{hwloc_obj_t}, Ptr{hwloc_uint64_t}, Culong), topology, handle, nbobjs, objs, values, flags)
end

@cenum hwloc_distances_add_flag_e::UInt32 begin
    HWLOC_DISTANCES_ADD_FLAG_GROUP = 1
    HWLOC_DISTANCES_ADD_FLAG_GROUP_INACCURATE = 2
end

function hwloc_distances_add_commit(topology, handle, flags)
    ccall((:hwloc_distances_add_commit, libhwloc), Cint, (hwloc_topology_t, hwloc_distances_add_handle_t, Culong), topology, handle, flags)
end

function hwloc_distances_remove(topology)
    ccall((:hwloc_distances_remove, libhwloc), Cint, (hwloc_topology_t,), topology)
end

function hwloc_distances_remove_by_depth(topology, depth)
    ccall((:hwloc_distances_remove_by_depth, libhwloc), Cint, (hwloc_topology_t, Cint), topology, depth)
end

function hwloc_distances_remove_by_type(topology, type)
    ccall((:hwloc_distances_remove_by_type, libhwloc), Cint, (hwloc_topology_t, hwloc_obj_type_t), topology, type)
end

function hwloc_distances_release_remove(topology, distances)
    ccall((:hwloc_distances_release_remove, libhwloc), Cint, (hwloc_topology_t, Ptr{hwloc_distances_s}), topology, distances)
end

@cenum hwloc_topology_diff_obj_attr_type_e::UInt32 begin
    HWLOC_TOPOLOGY_DIFF_OBJ_ATTR_SIZE = 0
    HWLOC_TOPOLOGY_DIFF_OBJ_ATTR_NAME = 1
    HWLOC_TOPOLOGY_DIFF_OBJ_ATTR_INFO = 2
end

const hwloc_topology_diff_obj_attr_type_t = hwloc_topology_diff_obj_attr_type_e

struct hwloc_topology_diff_obj_attr_u
    data::NTuple{32, UInt8}
end

function Base.getproperty(x::Ptr{hwloc_topology_diff_obj_attr_u}, f::Symbol)
    f === :generic && return Ptr{hwloc_topology_diff_obj_attr_generic_s}(x + 0)
    f === :uint64 && return Ptr{hwloc_topology_diff_obj_attr_uint64_s}(x + 0)
    f === :string && return Ptr{hwloc_topology_diff_obj_attr_string_s}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::hwloc_topology_diff_obj_attr_u, f::Symbol)
    r = Ref{hwloc_topology_diff_obj_attr_u}(x)
    ptr = Base.unsafe_convert(Ptr{hwloc_topology_diff_obj_attr_u}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{hwloc_topology_diff_obj_attr_u}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

@cenum hwloc_topology_diff_type_e::UInt32 begin
    HWLOC_TOPOLOGY_DIFF_OBJ_ATTR = 0
    HWLOC_TOPOLOGY_DIFF_TOO_COMPLEX = 1
end

const hwloc_topology_diff_type_t = hwloc_topology_diff_type_e

struct hwloc_topology_diff_u
    data::NTuple{56, UInt8}
end

function Base.getproperty(x::Ptr{hwloc_topology_diff_u}, f::Symbol)
    f === :generic && return Ptr{hwloc_topology_diff_generic_s}(x + 0)
    f === :obj_attr && return Ptr{hwloc_topology_diff_obj_attr_s}(x + 0)
    f === :too_complex && return Ptr{hwloc_topology_diff_too_complex_s}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::hwloc_topology_diff_u, f::Symbol)
    r = Ref{hwloc_topology_diff_u}(x)
    ptr = Base.unsafe_convert(Ptr{hwloc_topology_diff_u}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{hwloc_topology_diff_u}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

const hwloc_topology_diff_t = Ptr{hwloc_topology_diff_u}

function hwloc_topology_diff_build(topology, newtopology, flags, diff)
    ccall((:hwloc_topology_diff_build, libhwloc), Cint, (hwloc_topology_t, hwloc_topology_t, Culong, Ptr{hwloc_topology_diff_t}), topology, newtopology, flags, diff)
end

@cenum hwloc_topology_diff_apply_flags_e::UInt32 begin
    HWLOC_TOPOLOGY_DIFF_APPLY_REVERSE = 1
end

function hwloc_topology_diff_apply(topology, diff, flags)
    ccall((:hwloc_topology_diff_apply, libhwloc), Cint, (hwloc_topology_t, hwloc_topology_diff_t, Culong), topology, diff, flags)
end

function hwloc_topology_diff_destroy(diff)
    ccall((:hwloc_topology_diff_destroy, libhwloc), Cint, (hwloc_topology_diff_t,), diff)
end

function hwloc_topology_diff_load_xml(xmlpath, diff, refname)
    ccall((:hwloc_topology_diff_load_xml, libhwloc), Cint, (Ptr{Cchar}, Ptr{hwloc_topology_diff_t}, Ptr{Ptr{Cchar}}), xmlpath, diff, refname)
end

function hwloc_topology_diff_export_xml(diff, refname, xmlpath)
    ccall((:hwloc_topology_diff_export_xml, libhwloc), Cint, (hwloc_topology_diff_t, Ptr{Cchar}, Ptr{Cchar}), diff, refname, xmlpath)
end

function hwloc_topology_diff_load_xmlbuffer(xmlbuffer, buflen, diff, refname)
    ccall((:hwloc_topology_diff_load_xmlbuffer, libhwloc), Cint, (Ptr{Cchar}, Cint, Ptr{hwloc_topology_diff_t}, Ptr{Ptr{Cchar}}), xmlbuffer, buflen, diff, refname)
end

function hwloc_topology_diff_export_xmlbuffer(diff, refname, xmlbuffer, buflen)
    ccall((:hwloc_topology_diff_export_xmlbuffer, libhwloc), Cint, (hwloc_topology_diff_t, Ptr{Cchar}, Ptr{Ptr{Cchar}}, Ptr{Cint}), diff, refname, xmlbuffer, buflen)
end

function hwloc_distances_add(topology, nbobjs, objs, values, kind, flags)
    ccall((:hwloc_distances_add, libhwloc), Cint, (hwloc_topology_t, Cuint, Ptr{hwloc_obj_t}, Ptr{hwloc_uint64_t}, Culong, Culong), topology, nbobjs, objs, values, kind, flags)
end

function hwloc_topology_insert_misc_object_by_parent(topology, parent, name)
    ccall((:hwloc_topology_insert_misc_object_by_parent, libhwloc), hwloc_obj_t, (hwloc_topology_t, hwloc_obj_t, Ptr{Cchar}), topology, parent, name)
end

function hwloc_obj_cpuset_snprintf(str, size, nobj, objs)
    ccall((:hwloc_obj_cpuset_snprintf, libhwloc), Cint, (Ptr{Cchar}, Csize_t, Csize_t, Ptr{Ptr{hwloc_obj}}), str, size, nobj, objs)
end

function hwloc_obj_type_sscanf(string, typep, depthattrp, typeattrp, typeattrsize)
    ccall((:hwloc_obj_type_sscanf, libhwloc), Cint, (Ptr{Cchar}, Ptr{hwloc_obj_type_t}, Ptr{Cint}, Ptr{Cvoid}, Csize_t), string, typep, depthattrp, typeattrp, typeattrsize)
end

function hwloc_set_membind_nodeset(topology, nodeset, policy, flags)
    ccall((:hwloc_set_membind_nodeset, libhwloc), Cint, (hwloc_topology_t, hwloc_const_nodeset_t, hwloc_membind_policy_t, Cint), topology, nodeset, policy, flags)
end

function hwloc_get_membind_nodeset(topology, nodeset, policy, flags)
    ccall((:hwloc_get_membind_nodeset, libhwloc), Cint, (hwloc_topology_t, hwloc_nodeset_t, Ptr{hwloc_membind_policy_t}, Cint), topology, nodeset, policy, flags)
end

function hwloc_set_proc_membind_nodeset(topology, pid, nodeset, policy, flags)
    ccall((:hwloc_set_proc_membind_nodeset, libhwloc), Cint, (hwloc_topology_t, pid_t, hwloc_const_nodeset_t, hwloc_membind_policy_t, Cint), topology, pid, nodeset, policy, flags)
end

function hwloc_get_proc_membind_nodeset(topology, pid, nodeset, policy, flags)
    ccall((:hwloc_get_proc_membind_nodeset, libhwloc), Cint, (hwloc_topology_t, pid_t, hwloc_nodeset_t, Ptr{hwloc_membind_policy_t}, Cint), topology, pid, nodeset, policy, flags)
end

function hwloc_set_area_membind_nodeset(topology, addr, len, nodeset, policy, flags)
    ccall((:hwloc_set_area_membind_nodeset, libhwloc), Cint, (hwloc_topology_t, Ptr{Cvoid}, Csize_t, hwloc_const_nodeset_t, hwloc_membind_policy_t, Cint), topology, addr, len, nodeset, policy, flags)
end

function hwloc_get_area_membind_nodeset(topology, addr, len, nodeset, policy, flags)
    ccall((:hwloc_get_area_membind_nodeset, libhwloc), Cint, (hwloc_topology_t, Ptr{Cvoid}, Csize_t, hwloc_nodeset_t, Ptr{hwloc_membind_policy_t}, Cint), topology, addr, len, nodeset, policy, flags)
end

function hwloc_alloc_membind_nodeset(topology, len, nodeset, policy, flags)
    ccall((:hwloc_alloc_membind_nodeset, libhwloc), Ptr{Cvoid}, (hwloc_topology_t, Csize_t, hwloc_const_nodeset_t, hwloc_membind_policy_t, Cint), topology, len, nodeset, policy, flags)
end

function hwloc_alloc_membind_policy_nodeset(topology, len, nodeset, policy, flags)
    ccall((:hwloc_alloc_membind_policy_nodeset, libhwloc), Ptr{Cvoid}, (hwloc_topology_t, Csize_t, hwloc_const_nodeset_t, hwloc_membind_policy_t, Cint), topology, len, nodeset, policy, flags)
end

function hwloc_cpuset_to_nodeset_strict(topology, _cpuset, nodeset)
    ccall((:hwloc_cpuset_to_nodeset_strict, libhwloc), Cvoid, (hwloc_topology_t, hwloc_const_cpuset_t, hwloc_nodeset_t), topology, _cpuset, nodeset)
end

function hwloc_cpuset_from_nodeset_strict(topology, _cpuset, nodeset)
    ccall((:hwloc_cpuset_from_nodeset_strict, libhwloc), Cvoid, (hwloc_topology_t, hwloc_cpuset_t, hwloc_const_nodeset_t), topology, _cpuset, nodeset)
end

struct hwloc_topology_diff_generic_s
    type::hwloc_topology_diff_type_t
    next::Ptr{hwloc_topology_diff_u}
end

struct hwloc_topology_diff_obj_attr_s
    data::NTuple{56, UInt8}
end

function Base.getproperty(x::Ptr{hwloc_topology_diff_obj_attr_s}, f::Symbol)
    f === :type && return Ptr{hwloc_topology_diff_type_t}(x + 0)
    f === :next && return Ptr{Ptr{hwloc_topology_diff_u}}(x + 8)
    f === :obj_depth && return Ptr{Cint}(x + 16)
    f === :obj_index && return Ptr{Cuint}(x + 20)
    f === :diff && return Ptr{hwloc_topology_diff_obj_attr_u}(x + 24)
    return getfield(x, f)
end

function Base.getproperty(x::hwloc_topology_diff_obj_attr_s, f::Symbol)
    r = Ref{hwloc_topology_diff_obj_attr_s}(x)
    ptr = Base.unsafe_convert(Ptr{hwloc_topology_diff_obj_attr_s}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{hwloc_topology_diff_obj_attr_s}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct hwloc_topology_diff_too_complex_s
    type::hwloc_topology_diff_type_t
    next::Ptr{hwloc_topology_diff_u}
    obj_depth::Cint
    obj_index::Cuint
end

struct hwloc_memory_page_type_s
    size::hwloc_uint64_t
    count::hwloc_uint64_t
end

struct hwloc_numanode_attr_s
    local_memory::hwloc_uint64_t
    page_types_len::Cuint
    page_types::Ptr{hwloc_memory_page_type_s}
end

struct hwloc_cache_attr_s
    size::hwloc_uint64_t
    depth::Cuint
    linesize::Cuint
    associativity::Cint
    type::hwloc_obj_cache_type_t
end

struct hwloc_group_attr_s
    depth::Cuint
    kind::Cuint
    subkind::Cuint
    dont_merge::Cuchar
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

struct var"##Ctag#349"
    data::NTuple{24, UInt8}
end

function Base.getproperty(x::Ptr{var"##Ctag#349"}, f::Symbol)
    f === :pci && return Ptr{hwloc_pcidev_attr_s}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#349", f::Symbol)
    r = Ref{var"##Ctag#349"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#349"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#349"}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#350"
    data::NTuple{4, UInt8}
end

function Base.getproperty(x::Ptr{var"##Ctag#350"}, f::Symbol)
    f === :pci && return Ptr{var"##Ctag#351"}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#350", f::Symbol)
    r = Ref{var"##Ctag#350"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#350"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#350"}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct hwloc_bridge_attr_s
    data::NTuple{40, UInt8}
end

function Base.getproperty(x::Ptr{hwloc_bridge_attr_s}, f::Symbol)
    f === :upstream && return Ptr{var"##Ctag#349"}(x + 0)
    f === :upstream_type && return Ptr{hwloc_obj_bridge_type_t}(x + 24)
    f === :downstream && return Ptr{var"##Ctag#350"}(x + 28)
    f === :downstream_type && return Ptr{hwloc_obj_bridge_type_t}(x + 32)
    f === :depth && return Ptr{Cuint}(x + 36)
    return getfield(x, f)
end

function Base.getproperty(x::hwloc_bridge_attr_s, f::Symbol)
    r = Ref{hwloc_bridge_attr_s}(x)
    ptr = Base.unsafe_convert(Ptr{hwloc_bridge_attr_s}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{hwloc_bridge_attr_s}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#351"
    domain::Cushort
    secondary_bus::Cuchar
    subordinate_bus::Cuchar
end
function Base.getproperty(x::Ptr{var"##Ctag#351"}, f::Symbol)
    f === :domain && return Ptr{Cushort}(x + 0)
    f === :secondary_bus && return Ptr{Cuchar}(x + 2)
    f === :subordinate_bus && return Ptr{Cuchar}(x + 3)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#351", f::Symbol)
    r = Ref{var"##Ctag#351"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#351"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#351"}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end


struct hwloc_osdev_attr_s
    type::hwloc_obj_osdev_type_t
end

struct hwloc_topology_diff_obj_attr_generic_s
    type::hwloc_topology_diff_obj_attr_type_t
end

struct hwloc_topology_diff_obj_attr_uint64_s
    type::hwloc_topology_diff_obj_attr_type_t
    index::hwloc_uint64_t
    oldvalue::hwloc_uint64_t
    newvalue::hwloc_uint64_t
end

struct hwloc_topology_diff_obj_attr_string_s
    type::hwloc_topology_diff_obj_attr_type_t
    name::Ptr{Cchar}
    oldvalue::Ptr{Cchar}
    newvalue::Ptr{Cchar}
end

const HWLOC_VERSION = "2.8.0"

const HWLOC_VERSION_MAJOR = 2

const HWLOC_VERSION_MINOR = 8

const HWLOC_VERSION_RELEASE = 0

const HWLOC_VERSION_GREEK = ""

# TODO: this throws an error, should it even be included?
# const __hwloc_restrict = __restrict

# Skipping MacroDefinition: __hwloc_inline __inline__

const GXX_ABOVE_3_4 = 0

const GCC_ABOVE_2_95 = 1

const GCC_ABOVE_2_96 = 1

const GCC_ABOVE_3_3 = 1

const GCC_ABOVE_3_4 = 1

const __HWLOC_HAVE_ATTRIBUTE_UNUSED = GXX_ABOVE_3_4 | GCC_ABOVE_2_95

# Skipping MacroDefinition: __hwloc_attribute_unused __attribute__ ( ( __unused__ ) )

const __HWLOC_HAVE_ATTRIBUTE_MALLOC = GXX_ABOVE_3_4 | GCC_ABOVE_2_96

# Skipping MacroDefinition: __hwloc_attribute_malloc __attribute__ ( ( __malloc__ ) )

const __HWLOC_HAVE_ATTRIBUTE_CONST = GXX_ABOVE_3_4 | GCC_ABOVE_2_95

# Skipping MacroDefinition: __hwloc_attribute_const __attribute__ ( ( __const__ ) )

const __HWLOC_HAVE_ATTRIBUTE_PURE = GXX_ABOVE_3_4 | GCC_ABOVE_2_96

# Skipping MacroDefinition: __hwloc_attribute_pure __attribute__ ( ( __pure__ ) )

const __HWLOC_HAVE_ATTRIBUTE_DEPRECATED = GXX_ABOVE_3_4 | GCC_ABOVE_3_3

# Skipping MacroDefinition: __hwloc_attribute_deprecated __attribute__ ( ( __deprecated__ ) )

const __HWLOC_HAVE_ATTRIBUTE_MAY_ALIAS = GXX_ABOVE_3_4 | GCC_ABOVE_3_3

# Skipping MacroDefinition: __hwloc_attribute_may_alias __attribute__ ( ( __may_alias__ ) )

const __HWLOC_HAVE_ATTRIBUTE_WARN_UNUSED_RESULT = GXX_ABOVE_3_4 | GCC_ABOVE_3_4

# Skipping MacroDefinition: __hwloc_attribute_warn_unused_result __attribute__ ( ( __warn_unused_result__ ) )

const HWLOC_LINUX_SYS = 1

const HWLOC_HAVE_CPU_SET = 1

const hwloc_pid_t = pid_t

const hwloc_thread_t = pthread_t

const HWLOC_SYM_TRANSFORM = 0

const HWLOC_SYM_PREFIX = "hwloc_"

const HWLOC_SYM_PREFIX_CAPS = "HWLOC_"

const HWLOC_API_VERSION = 0x00020800

const HWLOC_COMPONENT_ABI = 7

const HWLOC_OBJ_TYPE_MIN = HWLOC_OBJ_MACHINE

const INT_MAX = typemax(Int64)
const HWLOC_TYPE_UNORDERED = INT_MAX

# TODO: The originial C defined HWLOC_UNKNOWN_INDEX as `(unsigned)-1` -- odd
# const HWLOC_UNKNOWN_INDEX = unsigned - 1
const HWLOC_UNKNOWN_INDEX = INT_MAX

const HWLOC_TOPOLOGY_FLAG_WHOLE_SYSTEM = HWLOC_TOPOLOGY_FLAG_INCLUDE_DISALLOWED

const HWLOC_OBJ_SYSTEM = HWLOC_OBJ_MACHINE

const HWLOC_OBJ_SOCKET = HWLOC_OBJ_PACKAGE

const HWLOC_OBJ_NODE = HWLOC_OBJ_NUMANODE

# exports
const PREFIXES = ["CX", "hwloc_"]
for name in names(@__MODULE__; all=true), prefix in PREFIXES
    if startswith(string(name), prefix)
        @eval export $name
    end
end

end # module
