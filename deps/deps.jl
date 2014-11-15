# This is an auto-generated file; do not edit

# Pre-hooks

# Macro to load a library
macro checked_lib(libname, path)
    (dlopen_e(path) == C_NULL) && error("Unable to load \n\n$libname ($path)\n\nPlease re-run Pkg.build(package), and restart Julia.")
    quote const $(esc(libname)) = $path end
end

# Load dependencies
@checked_lib libhwloc "/opt/local/lib/libhwloc.dylib"
@checked_lib libhwloc_helpers "/Users/eschnett/.julia/v0.4/hwloc/deps/usr/lib/libhwloc_helpers.dylib"

# Load-hooks

