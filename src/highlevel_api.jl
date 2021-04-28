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
    print_topology([io::IO = stdout, obj::Object = gettopology()])

Prints the topology of the given `obj` as a tree to `io`.
"""
function print_topology(io::IO = stdout, obj::Object = gettopology())
    t = hwloc_typeof(obj)
    idxstr = t in (:Package, :Core, :PU) ? "L#$(obj.logical_index) P#$(obj.os_index) " : ""
    attrstr = string(obj.attr)

    if t in (:L1Cache, :L2Cache, :L3Cache)
        tstr = first(string(t), 2)
        attrstr = "("*_bytes2string(obj.attr.size)*")"
    else
        tstr = string(t)
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
    return nothing
end
print_topology(obj::Object) = print_topology(stdout, obj)

"""
Returns the top-level system topology `Object`.
"""
gettopology() = machine_topology[]

"""
Prints the system topology as a tree.
"""
topology() = print_topology(gettopology())

"""
Prints a summary of the system topology (loosely similar to `hwloc-info`).
"""
function topology_info()
    nodes = Tuple{Symbol, Int64, String}[]
    for subobj in gettopology()
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
Programmatic version of `topology_info()`. Returns a `Dict{Symbol,Int}`
whose entries indicate which and how often certain hwloc elements are present.

If the keyword argument `list_all` (default: `false`) is set to `true`,
the resulting dictionary will contain all possible hwloc elements.
"""
function getinfo(; list_all::Bool = false)
    res = list_all ? Dict{Symbol,Int}(t => 0 for t in obj_types) : Dict{Symbol, Int}()
    for subobj in gettopology()
        t = hwloc_typeof(subobj)
        if t in keys(res)
            res[t] += 1
        else
            res[t] = 1
        end
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
collectobjects(type::Symbol, t::Object = gettopology()) = collect(Iterators.filter(hwloc_isa(type), t))

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
l3cache_sizes() = map(obj->obj.attr.size, Iterators.filter(obj->obj.type_ == :L3Cache, gettopology()))
"""
Returns a vector containing the L3 cache line sizes in Bytes.
"""
l3cache_linesizes() = map(obj->obj.attr.linesize, Iterators.filter(obj->obj.type_ == :L3Cache, gettopology()))

"""
Returns a vector containing the sizes of all available L2 caches in Bytes.
"""
l2cache_sizes() = map(obj->obj.attr.size, Iterators.filter(obj->obj.type_ == :L2Cache, gettopology()))
"""
Returns a vector containing the L2 cache line sizes in Bytes.
"""
l2cache_linesizes() = map(obj->obj.attr.linesize, Iterators.filter(obj->obj.type_ == :L2Cache, gettopology()))

"""
Returns a vector containing the sizes of all available L1 caches in Bytes.
"""
l1cache_sizes() = map(obj->obj.attr.size, Iterators.filter(obj->obj.type_ == :L1Cache, gettopology()))
"""
Returns a vector containing the L1 cache line sizes in Bytes.
"""
l1cache_linesizes() = map(obj->obj.attr.linesize, Iterators.filter(obj->obj.type_ == :L1Cache, gettopology()))

"""
Returns the L1, L2, and L3 cache sizes in Bytes.
(Produces a warning if caches of the same level have different sizes across the system.)
"""
function cachesize()
    allequal = xs -> all(x == first(xs) for x in xs)
    l1 = l1cache_sizes()
    l2 = l2cache_sizes()
    l3 = l3cache_sizes()

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
    allequal = xs -> all(x == first(xs) for x in xs)
    l1 = l1cache_linesizes()
    l2 = l2cache_linesizes()
    l3 = l3cache_linesizes()

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
            return string(round(y, digits=2), " kB")    
        end
    else
        return string(round(y, digits=2), " B")
    end
end