using Clang.Generators
using Hwloc.Hwloc_jll

cd(@__DIR__)

include_dir = normpath(Hwloc_jll.artifact_dir, "include")

options = load_options(joinpath(@__DIR__, "generator.toml"))

# Note you must call this function firstly and then append your own flags
args = get_default_args()
push!(args, "-I$include_dir")

headers = [
    joinpath(include_dir, header) for header in readdir(include_dir)
				  if endswith(header, ".h")
]
# # there is also an experimental `detect_headers` function for auto-detecting
# # top-level headers in the directory -- TODO: use this when no-logner
# # experimental:
# headers = detect_headers(clang_dir, args)

# create context
ctx = create_context(headers, args, options)

# run generator
build!(ctx)

