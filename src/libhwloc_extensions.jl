module LibHwlocExtensions

using ..LibHwloc: libhwloc

using CEnum

function hwloc_pci_class_string(class_id)
    val = ccall(
        (:hwloc_pci_class_string, libhwloc),
        Ptr{Cchar},
        (Cushort,),
        class_id
    )
    return unsafe_string(val)
end

end