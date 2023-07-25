import AbstractTrees

mutable struct HwlocTreeNode
    object::Object
    type::Symbol

    parent::Union{Nothing, HwlocTreeNode}
    children::Vector{HwlocTreeNode}
    memory_children::Vector{HwlocTreeNode}
    io_children::Vector{HwlocTreeNode}

    function HwlocTreeNode(obj::Object; parent=nothing, type=nothing)
        this = new(obj, obj.type_, parent)

        this.children = HwlocTreeNode.(obj.children; parent=this)
        this.memory_children = HwlocTreeNode.(obj.memory_children; parent=this)
        this.io_children = HwlocTreeNode.(obj.io_children; parent=this)
        
        return this
    end
end

function AbstractTrees.children(node::HwlocTreeNode)
    tuple(node.children..., node.memory_children..., node.io_children...)
end

AbstractTrees.nodevalue(n::HwlocTreeNode) = n.object

AbstractTrees.ParentLinks(::Type{<:HwlocTreeNode}) = StoredParents()

AbstractTrees.parent(n::HwlocTreeNode) = n.parent

AbstractTrees.NodeType(::Type{<:HwlocTreeNode}) where {T} = HasNodeType()
AbstractTrees.nodetype(::Type{<:HwlocTreeNode}) where {T} = HwlocTreeNode