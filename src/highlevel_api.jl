function get_api_version()
    version = ccall((:hwloc_get_api_version, libhwloc), Cuint, ())
    patch = version % 256
    version = version ÷ 256
    minor = version % 256
    version = version ÷ 256
    major = version
    VersionNumber(major, minor, patch)
end

function print_summary()
    topo = load_topology()
    nodes = Tuple{Symbol, Int64, String}[]
    for subobj in topo
        idx = findfirst(t->t[1] == subobj.type_, nodes)
        if isnothing(idx)
            attrstr = ""
            subobj.mem > 0 && (attrstr = " ($(bytes2string(subobj.mem)))")
            subobj.type_ ∈ (:L1Cache, :L2Cache, :L3Cache) && (attrstr = " ($(bytes2string(subobj.attr.size)))")
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

function topology()
    topo = load_topology()
    print_topology(topo)
    return topo
end

function print_topology(io::IO = stdout, obj::Object = load_topology())
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
        print_topology(io, child)
    end
end
print_topology(obj::Object) = print_topology(stdout, obj)


# Condense information similar to hwloc-info
function getinfo(obj::Object=load_topology())
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


# Collect objects of given type from topology.
collectobjects(t::Object, type_::Symbol) = collect(Iterators.filter(obj -> obj.type_ == type_, t))

attributes(obj::Object)=obj.attr

# Return number of cores
function num_physical_cores()
  topo = load_topology()
  histmap(topo)[:Core]
end


# Return number of processor packages (sockets). Compute servers usually consist
# of several packages which in turn contain several cores.
num_packages() = count(obj->obj.type_ == :Package, Hwloc.load_topology())

num_numa_nodes() = count(obj->obj.type_ == :NUMANode, Hwloc.load_topology())

# Return L3 cache sizes (in Bytes) of each package.
# Usually, L3 cache is shared by all cores in a package. 
l3cache_sizes(topo=load_topology()) = map(obj->obj.attr.size, Iterators.filter(obj->obj.type_ == :L3Cache, topo))
l3cache_linesizes(topo=load_topology()) = map(obj->obj.attr.linesize, Iterators.filter(obj->obj.type_ == :L3Cache, topo))

# Return L2 cache sizes (in Bytes) of each core.
l2cache_sizes(topo=load_topology()) = map(obj->obj.attr.size, Iterators.filter(obj->obj.type_ == :L2Cache, topo))
l2cache_linesizes(topo=load_topology()) = map(obj->obj.attr.linesize, Iterators.filter(obj->obj.type_ == :L2Cache, topo))

# Return L1 cache sizes (in Bytes) of each core.
l1cache_sizes(topo=load_topology()) = map(obj->obj.attr.size, Iterators.filter(obj->obj.type_ == :L1Cache, topo))
l1cache_linesizes(topo=load_topology()) = map(obj->obj.attr.linesize, Iterators.filter(obj->obj.type_ == :L1Cache, topo))

function cachesize()
    topo = load_topology()
    allequal = xs -> all(x == first(xs) for x in xs)
    l1 = l1cache_sizes(topo)
    l2 = l2cache_sizes(topo)
    l3 = l3cache_sizes(topo)

    allequal(l1) || (@warn "Not all L1 cache sizes are equal. Consider using `l1cache_sizes()` instead.")
    allequal(l2) || (@warn "Not all L2 cache sizes are equal. Consider using `l2cache_sizes()` instead.")
    allequal(l3) || (@warn "Not all L3 cache sizes are equal. Consider using `l3cache_sizes()` instead.")

    return (L1=first(l1), L2=first(l2), L3=first(l3))
end

function cachelinesize()
    topo = load_topology()
    allequal = xs -> all(x == first(xs) for x in xs)
    l1 = l1cache_linesizes(topo)
    l2 = l2cache_linesizes(topo)
    l3 = l3cache_linesizes(topo)

    allequal(l1) || (@warn "Not all L1 cache-line sizes are equal. Consider using `l1cache_linesizes()` instead.")
    allequal(l2) || (@warn "Not all L2 cache-line sizes are equal. Consider using `l2cache_linesizes()` instead.")
    allequal(l3) || (@warn "Not all L3 cache-line sizes are equal. Consider using `l3cache_linesizes()` instead.")

    return (L1=first(l1), L2=first(l2), L3=first(l3))
end


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