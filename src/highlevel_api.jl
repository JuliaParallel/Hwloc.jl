using ..LibHwloc: hwloc_get_api_version, HWLOC_OBJ_BRIDGE_HOST,
    HWLOC_OBJ_OSDEV_BLOCK, HWLOC_OBJ_OSDEV_GPU, HWLOC_OBJ_OSDEV_NETWORK,
    HWLOC_OBJ_OSDEV_OPENFABRICS, HWLOC_OBJ_OSDEV_DMA, HWLOC_OBJ_OSDEV_COPROC

using Printf

"""
Returns the API version of libhwloc.
"""
function get_api_version()
    version = hwloc_get_api_version()
    patch = version % 256
    version = version ÷ 256
    minor = version % 256
    version = version ÷ 256
    major = version
    VersionNumber(major, minor, patch)
end

const minimal_classes = [
    "VGA", "NVMExp", "SATA", "Network", "Ethernet", "InfiniBand", "3D", "Other"
]
subtype_str(obj) = obj.subtype == "" ? "" : "($(obj.subtype))"

function is_visible(obj::Object; minimal=true)
    t = hwloc_typeof(obj)

    if t == :Bridge
        for child in obj.io_children
            if is_visible(child)
                return true
            end
        end
        return false
    end

    if t == :PCI_Device
        if minimal
            class_string = hwloc_pci_class_string(obj.attr.class_id)
            return class_string in minimal_classes
        else
            return true
        end
    end

    return true
end

"""
    print_topology(
        io::IO = stdout, obj::Object = gettopology();
        indent = "", newline = true, prefix = "", minimal=true
    )

Prints the topology of the given `obj` as a tree to `io`.

**Note:** some systems have a great deal of extra PCI devices (think USB
bridges, and the many many device classes on custom systems like HPC clusters).
In order to mimmic the behaviour of the `lstopo` command, we ommit these devices
unless `minimal=false`.
"""
function print_topology(
    io::IO=stdout, obj::Object=gettopology();
    indent="", newline=true, prefix="", minimal=true
)
    t = hwloc_typeof(obj)

    idxstr = t in (:Package, :Core, :PU) ? "L#$(obj.logical_index) P#$(obj.os_index) " : ""
    attrstr = string(obj.attr)

    # this is set to false whenever minimal == true and the PCI class_id strings
    # don't match the minimal_classes list
    print_device = is_visible(obj; minimal=minimal)

    if t in (:L1Cache, :L2Cache, :L3Cache, :L1ICache)
        tstr = first(string(t), 2)
        attrstr = "(" * _bytes2string(obj.attr.size) * ")"
    elseif t == :Bridge
        if obj.attr.upstream_type == HWLOC_OBJ_BRIDGE_HOST
            tstr = "HostBridge"
            attrstr = ""
        else
            tstr = "PCIBridge"
            attrstr = ""
        end
    elseif t == :PCI_Device
        class_string = hwloc_pci_class_string(obj.attr.class_id)
        tstr = "PCI"
        attrstr = obj.attr.domain == 0 ? "" : @sprintf("%04x:", obj.attr.domain)
        attrstr *= @sprintf("%02x:%02x.%01x",
            obj.attr.bus, obj.attr.dev, obj.attr.func
        ) * " ($(class_string))"
    elseif t == :OS_Device
        attrstr = "\"$(obj.name)\""
        tstr = if obj.attr.type == HWLOC_OBJ_OSDEV_BLOCK
            "Block$(subtype_str(obj))"
        elseif obj.attr.type == HWLOC_OBJ_OSDEV_GPU
            "GPU"
        elseif obj.attr.type == HWLOC_OBJ_OSDEV_NETWORK
            "Net"
        elseif obj.attr.type == HWLOC_OBJ_OSDEV_OPENFABRICS
            "OpenFabrics"
        elseif obj.attr.type == HWLOC_OBJ_OSDEV_DMA
            "DMA"
        elseif obj.attr.type == HWLOC_OBJ_OSDEV_COPROC
            "CoProc$(subtype_str(obj))"
        else
            string(obj.attr)
        end
    else
        tstr = string(t)
        attrstr = obj.name
    end

    if print_device
        newline && print(io, "\n", indent)
        print(
            io, prefix, tstr, " ", idxstr, attrstr,
            obj.mem > 0 ? "(" * _bytes2string(obj.mem) * ")" : ""
        )
    else
        return nothing
    end

    for memchild in obj.memory_children
        memstr = "(" * _bytes2string(memchild.mem) * ")"
        println(io)
        print(io, indent * repeat(" ", 4), string(memchild.type_), " ", memstr)
    end

    for child in obj.children
        no_newline = length(obj.children) == 1 && t in (:L3Cache, :L2Cache, :L1Cache)
        if no_newline
            print_topology(
                io, child;
                indent=indent, newline=false, prefix=" + ", minimal=minimal
            )
        else
            print_topology(
                io, child;
                indent=indent * repeat(" ", 4), newline=true, minimal=minimal
            )
        end
    end

    for child in obj.io_children
        print_topology(
            io, child;
            indent=indent * repeat(" ", 4), newline=true, minimal=minimal
        )
    end

    return nothing
end
print_topology(obj::Object) = print_topology(stdout, obj)

"""
Returns the top-level system topology `Object`.

On first call, it loads the topology by querying libhwloc and caches the result.
Pass `reload=true` in order to force reload.
"""
function gettopology(htopo=nothing; reload=false, io=true)
    if reload || (!isassigned(machine_topology))
        if isnothing(htopo)
            htopo = topology_init(; io=io)
        end
        machine_topology[] = topology_load(htopo)
    end

    return machine_topology[]
end

"""
Prints the system topology as a tree.
"""
topology(topo=gettopology()) = print_topology(topo)

"""
    topology_info(topo=gettopology())

Prints a summary of the system topology (loosely similar to `hwloc-info`).
"""
function topology_info(topo=gettopology())
    nodes = Tuple{Symbol,Int64,String}[]
    for subobj in topo
        idx = findfirst(t -> t[1] == subobj.type_, nodes)
        if isnothing(idx)
            attrstr = ""
            subobj.mem > 0 && (attrstr = " ($(_bytes2string(subobj.mem)))")
            subobj.type_ ∈ (:L1Cache, :L2Cache, :L3Cache) && (attrstr = " ($(_bytes2string(subobj.attr.size)))")
            push!(nodes, (subobj.type_, 1, attrstr))
        else
            nodes[idx] = (subobj.type_, nodes[idx][2] + 1, nodes[idx][3])
        end
    end

    for (i, n) in enumerate(nodes)
        println(repeat(" ", i - 1), "$(n[1]): ", n[2], n[3])
    end
    return nothing
end

"""
    getinfo(topo=gettopology(); list_all=false)

Programmatic version of `topology_info()`. Returns a `Dict{Symbol,Int}`
whose entries indicate which and how often certain hwloc elements are present.

If the `list_all` kwarg is `true`, then the results Dict will have a key for
each Hwloc type. **Warning:** a zero count does not necessarily mean that such
a device is not present -- e.g. the following
```
getinfo(gettopology(;reload=true, io=false); list_all=true)
```
will show a `PCI_Device` count of zero, even though those devices are present
(the zero count is due to the `io=false` kwarg passed to `gettopology`).
"""
function getinfo(topo=gettopology(); list_all=false)
    res = list_all ? Dict{Symbol,Int}(t => 0 for t in obj_types) : Dict{Symbol,Int}()
    for subobj in topo
        t = hwloc_typeof(subobj)
        res[t] = get!(res, t, 0) + 1
    end
    return res
end

"""
Returns the hwloc "type" of the given `Hwloc.Object` as a `Symbol`.
For example, `hwloc_typeof(topology_load()) == :Machine`.
"""
hwloc_typeof(obj::Object) = obj.type_

"""
    hwloc_isa(obj::Object, type::Symbol)

Checks if `hwloc_typeof(obj) == type`.
For example, `hwloc_isa(topology_load(), :Machine) == true`.
"""
hwloc_isa(obj::Object, type::Symbol) = hwloc_typeof(obj) == type

"""
    hwloc_isa(type::Symbol)

Returns a function `obj::Object -> Bool` that checks whether a given object is of type `type` (in the sense of `hwloc_typeof`).
"""
hwloc_isa(type::Symbol) = obj -> hwloc_typeof(obj) == type

"""
    collectobjects(type::Symbol[, t::Object = gettopology()])

Collects objects of the given hwloc `type` from the (sub-)topology tree `t`.
"""
collectobjects(type::Symbol, t::Object=gettopology()) = collect(Iterators.filter(hwloc_isa(type), t))

"""
The number of physical cores.
"""
num_physical_cores() = count(hwloc_isa(:Core), gettopology())

"""
The number of virtual cores, i.e. logical processing units.
"""
num_virtual_cores() = count(hwloc_isa(:PU), gettopology())

"""
The number of processor packages (sockets).
"""
num_packages() = count(hwloc_isa(:Package), gettopology())

"""
The number of NUMA nodes.
"""
num_numa_nodes() = count(hwloc_isa(:NUMANode), gettopology())

"""
Returns a vector containing the sizes of all available L3 caches in Bytes.
"""
l3cache_sizes() = map(obj -> obj.attr.size, Iterators.filter(obj -> obj.type_ == :L3Cache, gettopology()))
"""
Returns a vector containing the L3 cache line sizes in Bytes.
"""
l3cache_linesizes() = map(obj -> obj.attr.linesize, Iterators.filter(obj -> obj.type_ == :L3Cache, gettopology()))

"""
Returns a vector containing the sizes of all available L2 caches in Bytes.
"""
l2cache_sizes() = map(obj -> obj.attr.size, Iterators.filter(obj -> obj.type_ == :L2Cache, gettopology()))
"""
Returns a vector containing the L2 cache line sizes in Bytes.
"""
l2cache_linesizes() = map(obj -> obj.attr.linesize, Iterators.filter(obj -> obj.type_ == :L2Cache, gettopology()))

"""
Returns a vector containing the sizes of all available L1 caches in Bytes.
"""
l1cache_sizes() = map(obj -> obj.attr.size, Iterators.filter(obj -> obj.type_ == :L1Cache, gettopology()))
"""
Returns a vector containing the L1 cache line sizes in Bytes.
"""
l1cache_linesizes() = map(obj -> obj.attr.linesize, Iterators.filter(obj -> obj.type_ == :L1Cache, gettopology()))

"""
    cachesize()
Returns the L1, L2, and L3 cache sizes in Bytes.
(Produces a warning if caches of the same level have different sizes across the system.)
"""
function cachesize()
    allequal = xs -> all(x == first(xs) for x in xs)

    l1 = l1cache_sizes()
    l2 = l2cache_sizes()
    l3 = l3cache_sizes()

    isempty(l1) && throw(ErrorException("Your system doesn't seem to have an L1 cache."))
    isempty(l2) && throw(ErrorException("Your system doesn't seem to have an L2 cache."))
    isempty(l3) && throw(ErrorException("Your system doesn't seem to have an L3 cache."))

    allequal(l1) || (@warn "Not all L1 cache sizes are equal. Consider using `l1cache_sizes()` instead.")
    allequal(l2) || (@warn "Not all L2 cache sizes are equal. Consider using `l2cache_sizes()` instead.")
    allequal(l3) || (@warn "Not all L3 cache sizes are equal. Consider using `l3cache_sizes()` instead.")

    return (L1=maximum(l1), L2=maximum(l2), L3=maximum(l3))
end

"""
    cachesize(x::Symbol) -> size
Returns the size of the specified cache type. Allowed inputs are `:L1`, `:L2`, and `:L3`.
(Produces a warning if caches of the specified kind have different sizes across the system.)
"""
function cachesize(x::Symbol)
    allequal = xs -> all(x == first(xs) for x in xs)
    if x == :L1
        lx = l1cache_sizes()
    elseif x == :L2
        lx = l2cache_sizes()
    elseif x == :L3
        lx = l3cache_sizes()
    else
        throw(ArgumentError("Only :L1, :L2, and :L3 are allowed inputs."))
    end
    isempty(lx) && throw(ErrorException("Your system doesn't seem to have an $x cache."))
    allequal(lx) || (@warn "Not all $x cache sizes are equal.")
    return maximum(lx)
end

"""
Returns the L1, L2, and L3 cache line sizes in Bytes.
(Produces a warning if cache line sizes vary between caches of the same level across the system.)
"""
function cachelinesize()
    allequal = xs -> all(x == first(xs) for x in xs)
    l1 = l1cache_linesizes()
    l2 = l2cache_linesizes()
    l3 = l3cache_linesizes()

    isempty(l1) && throw(ErrorException("Your system doesn't seem to have an L1 cache."))
    isempty(l2) && throw(ErrorException("Your system doesn't seem to have an L2 cache."))
    isempty(l3) && throw(ErrorException("Your system doesn't seem to have an L3 cache."))

    allequal(l1) || (@warn "Not all L1 cache line sizes are equal. Consider using `l1cache_linesizes()` instead.")
    allequal(l2) || (@warn "Not all L2 cache line sizes are equal. Consider using `l2cache_linesizes()` instead.")
    allequal(l3) || (@warn "Not all L3 cache line sizes are equal. Consider using `l3cache_linesizes()` instead.")

    return (L1=maximum(l1), L2=maximum(l2), L3=maximum(l3))
end

"""
    cachelinesize(x::Symbol) -> size
Returns the size of a cache line of the specified cache type. Allowed inputs are `:L1`, `:L2`, and `:L3`.
(Produces a warning if cache line sizes vary between caches of the specified kind across the system.)
"""
function cachelinesize(x::Symbol)
    allequal = xs -> all(x == first(xs) for x in xs)
    if x == :L1
        lx = l1cache_linesizes()
    elseif x == :L2
        lx = l2cache_linesizes()
    elseif x == :L3
        lx = l3cache_linesizes()
    else
        throw(ArgumentError("Only :L1, :L2, and :L3 are allowed inputs."))
    end
    isempty(lx) && throw(ErrorException("Your system doesn't seem to have an $x cache."))
    allequal(lx) || (@warn "Not all $x cache line sizes are equal.")
    return maximum(lx)
end


function _bytes2string(x::Integer)
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
            return string(round(y, digits=2), " kB")
        end
    else
        return string(round(y, digits=2), " B")
    end
end

has_object_of_type(t) = any(obj -> obj.type_ == t, gettopology())

"""
Shows a graphical visualization of the system topology.
The quality of the result might depend on the used terminal and might vary between machines and operating systems.

**Note:** The specific visualization may change between minor versions.
"""
function topology_graphical(; io=true)
    if io
        run(`$(lstopo_no_graphics()) --no-legend --of txt`)
    else
        run(`$(lstopo_no_graphics()) --no-io --no-legend --of txt`)
    end
    return nothing
end

"""
Get the number of different kinds of CPU cores (e.g. efficiency and performance cores)
in the topology.
"""
num_cpukinds() = length(get_cpukind_info())

"""
For each kind of CPU cores, get the number of cores in the topology that are of that kind.
Typically, sorting is by efficiency (descending order). Hence, efficiency cores come before
performance cores.
"""
function num_cores_cpukinds()
    cki = get_cpukind_info()
    if nothing in cki
        return nothing
    end
    return [count_set_bits(cki[i].mask) for i in eachindex(cki)]
end
