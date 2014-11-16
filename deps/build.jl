using BinDeps
@BinDeps.setup

include("../src/compatibility.jl")



libhwloc = library_dependency("libhwloc")



# Install via a package manager
provides(AptGet, @Dict("libhwloc-dev" => libhwloc))

@osx_only begin
    using Homebrew
    provides(Homebrew.HB, Dict("hwloc" => libhwloc))
end

#unsupported provides(Port, Dict("hwloc" => libhwloc))

#untested provides(Yum, Dict("hwloc-devel" => libhwloc))

# Build from source
provides(Sources,
         @Dict(URI("http://www.open-mpi.org/software/hwloc/v1.10/downloads/hwloc-1.10.0.tar.gz") => libhwloc))
provides(BuildProcess, @Dict(Autotools(libtarget="src/libhwloc.la",
                                       configure_options=["--without-x"]) =>
                             libhwloc))



@BinDeps.install Dict([(:libhwloc, :libhwloc)])
