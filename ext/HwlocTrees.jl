module HwlocTrees

using Hwloc, Printf
import AbstractTrees

mutable struct HwlocTreeNode{T}
    object::Hwloc.Object
    type::Symbol
    tag::Union{Nothing, T}

    parent::Union{Nothing, HwlocTreeNode{T}}
    children::Vector{HwlocTreeNode{T}}
    memory_children::Vector{HwlocTreeNode{T}}
    io_children::Vector{HwlocTreeNode{T}}

    function HwlocTreeNode{T}(obj::Hwloc.Object; parent=nothing, type=nothing) where {T}
        this = new{T}(obj, obj.type_, nothing, parent)

        this.children = HwlocTreeNode{T}.(obj.children; parent=this)
        this.memory_children = HwlocTreeNode{T}.(obj.memory_children; parent=this)
        this.io_children = HwlocTreeNode{T}.(obj.io_children; parent=this)

        return this
    end
end

function AbstractTrees.children(node::Hwloc.Object)
    HwlocTreeNode{UInt8}(node)
end

function AbstractTrees.children(node::HwlocTreeNode)
    tuple(node.memory_children..., node.children..., node.io_children...)
end

AbstractTrees.nodevalue(n::HwlocTreeNode) = n.object

AbstractTrees.ParentLinks(::Type{<:HwlocTreeNode}) = AbstractTrees.StoredParents()

AbstractTrees.parent(n::HwlocTreeNode) = n.parent

AbstractTrees.NodeType(::Type{<:HwlocTreeNode{T}}) where {T} = AbstractTrees.HasNodeType()
AbstractTrees.nodetype(::Type{<:HwlocTreeNode{T}}) where {T} = HwlocTreeNode{T}

function AbstractTrees.printnode(io::IO, node::HwlocTreeNode)
    obj = AbstractTrees.nodevalue(node)
    label = string(obj)
    if node.type in (:Package, :Core, :PU)
        label = label * " [L#$(obj.logical_index) P#$(obj.os_index)]"
    elseif node.type == :Bridge
        if obj.attr.upstream_type == Hwloc.LibHwloc.HWLOC_OBJ_BRIDGE_HOST
            label = label * " [HostBridge]"
        else
            label = label * " [PCIBridge]"
        end
    elseif node.type == :PCI_Device
        class_string = Hwloc.LibHwlocExtensions.hwloc_pci_class_string(obj.attr.class_id)
        label = label * " [" * @sprintf(
            "%s%02x:%02x.%01x",
            Char(obj.attr.domain), obj.attr.bus, obj.attr.dev, obj.attr.func
        ) * " ($(class_string))]"
    elseif node.type == :OS_Device
        label = label * " [" * if obj.attr.type == Hwloc.LibHwloc.HWLOC_OBJ_OSDEV_BLOCK
            "Block$(Hwloc.subtype_str(obj))"
        elseif obj.attr.type == Hwloc.LibHwloc.HWLOC_OBJ_OSDEV_GPU
            "GPU"
        elseif obj.attr.type == Hwloc.LibHwloc.HWLOC_OBJ_OSDEV_NETWORK
            "Net"
        elseif obj.attr.type == Hwloc.LibHwloc.HWLOC_OBJ_OSDEV_OPENFABRICS
            "OpenFabrics"
        elseif obj.attr.type == Hwloc.LibHwloc.HWLOC_OBJ_OSDEV_DMA
            "DMA"
        elseif obj.attr.type == Hwloc.LibHwloc.HWLOC_OBJ_OSDEV_COPROC
            "CoProc$(Hwloc.subtype_str(obj))"
        else
            string(obj.attr)
        end * " \"$(obj.name)\"]"
    end
    print(io, label)
end

get_nodes(tree_node, type) = filter(
    x->x.type == type,
    collect(AbstractTrees.PreOrderDFS(tree_node))
)

function tag_subtree!(tree_node, val)
    for n in collect(AbstractTrees.PreOrderDFS(tree_node))
        n.tag = val
    end
end
end
