module hwloc

import Base: isempty, start, done, next, length
import Base: show
import Base: hist

using BinDeps
include("../deps/deps.jl")

export get_api_version, topology_load, hist, info



# Note: This must correspond to <hwloc.h>
const obj_types = Symbol[:System, :Machine, :Node, :Socket, :Cache, :Core, :PU,
                         :Group, :Misc, :Bridge, :PCI_Device, :OS_Device,
                         :Error]

type Object
    obj_type::Symbol
    os_index::Int
    name::ASCIIString
    depth::Int
    logical_index::Int
    os_level::Int
    children::Vector{Object}
    Object() = new(:Error, -1, "(nothing)", -1, -1, -1, Object[])
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
    println(io, repeat(" ", 4*max(0,obj.depth)), "D$(obj.depth): ",
            "$(string(obj.obj_type)) ",
            "L$(obj.logical_index) P$(obj.os_index) $(obj.name)")
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
    
    nroots = int(ccall((:hwloc_get_nbobjs_by_depth, libhwloc), Cuint,
                       (Ptr{Void}, Cuint), htopo, 0))
    @assert nroots == 1
    root = ccall((:hwloc_get_obj_by_depth, libhwloc), Ptr{Void},
                 (Ptr{Void}, Cuint, Cuint), htopo, 0, 0)
    topo = load(root)
    
    ccall((:hwloc_topology_destroy, libhwloc), Void, (Ptr{Void},), htopo)
    
    return topo
end

# Load topology for an object and all its children
function load(hobj::Ptr{Void})
    @assert hobj != C_NULL
    topo = Object()
    
    htype = int(ccall((:hwloc_get_obj_type, libhwloc_helpers), Cint,
                      (Ptr{Void},), hobj))
    @assert htype>=0 && htype<length(obj_types)
    topo.obj_type = obj_types[htype+1]
    
    topo.os_index = int(ccall((:hwloc_get_obj_os_index, libhwloc_helpers),
                              Cuint, (Ptr{Void},), hobj))
    
    cname = ccall((:hwloc_get_obj_name, libhwloc_helpers), Ptr{Cchar},
                  (Ptr{Void},), hobj)
    topo.name = cname == C_NULL ? "" : bytestring(cname)
    
    topo.depth = int(ccall((:hwloc_get_obj_depth, libhwloc_helpers), Cuint,
                           (Ptr{Void},), hobj))
    
    topo.logical_index = int(ccall((:hwloc_get_obj_logical_index,
                                    libhwloc_helpers),
                                   Cuint, (Ptr{Void},), hobj))
    
    topo.os_level = int(ccall((:hwloc_get_obj_os_level, libhwloc_helpers), Cint,
                              (Ptr{Void},), hobj))
    
    nchildren = int(ccall((:hwloc_get_obj_arity, libhwloc_helpers), Cuint,
                          (Ptr{Void},), hobj))
    children = Array(Ptr{Void}, nchildren)
    hchildren = ccall((:hwloc_get_obj_children, libhwloc_helpers), Ptr{Void},
                      (Ptr{Void},), hobj)
    ccall(:memcpy, Ptr{Void}, (Ptr{Void}, Ptr{Void}, Csize_t), children,
          hchildren, nchildren*sizeof(Ptr{Void}))
    
    for child in children
        @assert child != C_NULL
        push!(topo.children, load(child))
    end
    
    return topo
end



# Condense information similar to hwloc-info
function info(obj::Object)
    maxdepth = mapreduce(obj->obj.depth, max, 0, obj)
    types = fill(:Error, maxdepth+1)
    foldl((_,obj)->(types[obj.depth+1] = obj.obj_type; nothing), nothing, obj)
    counts = fill(0, maxdepth+1)
    foldl((_,obj)->(counts[obj.depth+1] += 1; nothing), nothing, obj)
    return collect(zip(types, counts))
end



# Create a histogram
function hist(obj::Object)
    counts = Dict{Symbol,Int}()
    for obj_type in obj_types
        counts[obj_type] = 0
    end
    foldl((_,obj)->(counts[obj.obj_type]+=1; nothing), nothing, obj)
    return obj_types, [counts[t] for t in obj_types]
end

end
