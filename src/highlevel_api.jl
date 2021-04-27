"""
Returns the API version of libhwloc.
"""
function get_api_version()
    version = ccall((:hwloc_get_api_version, libhwloc), Cuint, ())
    patch = version % 256
    version = version ÷ 256
    minor = version % 256
    version = version ÷ 256
    major = version
    VersionNumber(major, minor, patch)
end

"""
Prints a summary of the system topology (loosely similar to `hwloc-info`).
"""
function print_summary()
    topo = topology_load()
    nodes = Tuple{Symbol, Int64, String}[]
    for subobj in topo
        idx = findfirst(t->t[1] == subobj.type_, nodes)
        if isnothing(idx)
            attrstr = ""
            subobj.mem > 0 && (attrstr = " ($(_bytes2string(subobj.mem)))")
            subobj.type_ ∈ (:L1Cache, :L2Cache, :L3Cache) && (attrstr = " ($(_bytes2string(subobj.attr.size)))")
            push!(nodes, (subobj.type_, 1, attrstr))
        else
            nodes[idx] = (subobj.type_, nodes[idx][2]+1, nodes[idx][3])
        end
    end

    for (i,n) in enumerate(nodes)
        println(repeat(" ", i-1), "$(n[1]): ", n[2], n[3])
    end
    return nothing
end

"""
Prints the system topology as a tree and returns the toplevel `Hwloc.Object`.
"""
function topology()
    topo = topology_load()
    print_topology(topo)
    return topo
end

"""
Prints the system topology as a tree.
"""
function print_topology(io::IO = stdout, obj::Object = topology_load())
    idxstr = obj.type_ in (:Package, :Core, :PU) ? "L#$(obj.logical_index) P#$(obj.os_index) " : ""
    attrstr = string(obj.attr)

    if obj.type_ in (:L1Cache, :L2Cache, :L3Cache)
        tstr = first(string(obj.type_), 2)
        attrstr = "("*_bytes2string(obj.attr.size)*")"
    else
        tstr = string(obj.type_)
    end

    println(io, repeat(" ", 4*max(0,obj.depth)), tstr, " ",
        idxstr,
        attrstr, obj.mem > 0 ? "("*_bytes2string(obj.mem)*")" : "")

    for memchild in obj.memory_children
        memstr = "("*_bytes2string(memchild.mem)*")"
        println(io, repeat(" ", 4*max(0,obj.depth) + 4), string(memchild.type_), " ", memstr)
    end

    for child in obj.children
        print_topology(io, child)
    end
end
print_topology(obj::Object) = print_topology(stdout, obj)


"""
Returns a vector of 
"""
function getinfo(obj::Object=topology_load())
    res = Tuple{Symbol, Int64}[]
    for subobj in obj
        idx = findfirst(t->t[1] == subobj.type_, res)
        if isnothing(idx)
            push!(res, (subobj.type_, 1))
        else
            res[idx] = (subobj.type_, res[idx][2]+1)
        end
    end
    return res
end

# Create a histogram
function histmap(obj::Object)
    counts = Dict{Symbol,Int}([(t, 0) for t in obj_types])
    for subobj in obj
        counts[subobj.type_] += 1
    end
    return counts
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
Collects objects of the given hwloc type from topology.
"""
collectobjects(t::Object, type::Symbol) = collect(Iterators.filter(hwloc_isa(type), t))

"""
The number of physical cores.
"""
num_physical_cores() = count(hwloc_isa(:Core), topology_load())

"""
The number of virtual cores, i.e. logical processing units.
"""
num_virtual_cores() = count(hwloc_isa(:PU), topology_load())

"""
The number of processor packages (sockets).
"""
num_packages() = count(obj->obj.type_ == :Package, Hwloc.topology_load())

"""
The number of NUMA nodes.
"""
num_numa_nodes() = count(obj->obj.type_ == :NUMANode, Hwloc.topology_load())

"""
Returns a vector containing the sizes of all available L3 caches in Bytes.
"""
l3cache_sizes(topo=topology_load()) = map(obj->obj.attr.size, Iterators.filter(obj->obj.type_ == :L3Cache, topo))
"""
Returns a vector containing the L3 cache line sizes in Bytes.
"""
l3cache_linesizes(topo=topology_load()) = map(obj->obj.attr.linesize, Iterators.filter(obj->obj.type_ == :L3Cache, topo))

"""
Returns a vector containing the sizes of all available L2 caches in Bytes.
"""
l2cache_sizes(topo=topology_load()) = map(obj->obj.attr.size, Iterators.filter(obj->obj.type_ == :L2Cache, topo))
"""
Returns a vector containing the L2 cache line sizes in Bytes.
"""
l2cache_linesizes(topo=topology_load()) = map(obj->obj.attr.linesize, Iterators.filter(obj->obj.type_ == :L2Cache, topo))

"""
Returns a vector containing the sizes of all available L1 caches in Bytes.
"""
l1cache_sizes(topo=topology_load()) = map(obj->obj.attr.size, Iterators.filter(obj->obj.type_ == :L1Cache, topo))
"""
Returns a vector containing the L1 cache line sizes in Bytes.
"""
l1cache_linesizes(topo=topology_load()) = map(obj->obj.attr.linesize, Iterators.filter(obj->obj.type_ == :L1Cache, topo))

"""
Returns the L1, L2, and L3 cache sizes in Bytes.
(Produces a warning if caches of the same level have different sizes across the system.)
"""
function cachesize()
    topo = topology_load()
    allequal = xs -> all(x == first(xs) for x in xs)
    l1 = l1cache_sizes(topo)
    l2 = l2cache_sizes(topo)
    l3 = l3cache_sizes(topo)

    allequal(l1) || (@warn "Not all L1 cache sizes are equal. Consider using `l1cache_sizes()` instead.")
    allequal(l2) || (@warn "Not all L2 cache sizes are equal. Consider using `l2cache_sizes()` instead.")
    allequal(l3) || (@warn "Not all L3 cache sizes are equal. Consider using `l3cache_sizes()` instead.")

    return (L1=first(l1), L2=first(l2), L3=first(l3))
end

"""
Returns the L1, L2, and L3 cache line sizes in Bytes.
(Produces a warning if cache line sizes vary between caches of the same level across the system.)
"""
function cachelinesize()
    topo = topology_load()
    allequal = xs -> all(x == first(xs) for x in xs)
    l1 = l1cache_linesizes(topo)
    l2 = l2cache_linesizes(topo)
    l3 = l3cache_linesizes(topo)

    allequal(l1) || (@warn "Not all L1 cache line sizes are equal. Consider using `l1cache_linesizes()` instead.")
    allequal(l2) || (@warn "Not all L2 cache line sizes are equal. Consider using `l2cache_linesizes()` instead.")
    allequal(l3) || (@warn "Not all L3 cache line sizes are equal. Consider using `l3cache_linesizes()` instead.")

    return (L1=first(l1), L2=first(l2), L3=first(l3))
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
            return string(round(y, digits=2), " KB")    
        end
    else
        return string(round(y, digits=2), " B")
    end
end