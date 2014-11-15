using BinDeps

@BinDeps.setup



libhwloc = library_dependency("libhwloc")
libhwloc_helpers = library_dependency("libhwloc_helpers")

# Install via a package manager
provides(AptGet, Dict("libhwloc-dev" => libhwloc))

#fails @osx_only begin
#fails     using Homebrew
#fails     provides(Homebrew.HB, Dict("hwloc" => libhwloc))
#fails end

provides(Port, Dict("hwloc" => libhwloc))

#untested provides(Yum, Dict("hwloc-devel" => libhwloc))

# Build from source
#untested provides(Sources,
#untested          Dict(URI("http://www.open-mpi.org/software/hwloc/v1.10/downloads/hwloc-1.10.0.tar.gz") => libhwloc))
#untested provides(BuildProcess, Dict(Autotools(libtarget = "libhwloc.la") => libhwloc))



srcdir = joinpath(BinDeps.depsdir(libhwloc_helpers), "src", "libhwloc_helpers")
destdir = joinpath(BinDeps.depsdir(libhwloc_helpers), "usr")
provides(SimpleBuild,
         (@build_steps begin
             MakeTargets(srcdir, ["all", "HWLOC_DIRS=/opt/local"])
             MakeTargets(srcdir, ["install", "PREFIX=$(destdir)"])
          end),
         libhwloc_helpers)



@BinDeps.install Dict(:libhwloc => :libhwloc,
                      :libhwloc_helpers => :libhwloc_helpers)
