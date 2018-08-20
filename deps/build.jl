using BinDeps

@BinDeps.setup

libhwloc = library_dependency("libhwloc", aliases=["libhwloc-5"])

# Install via a package manager
if Sys.isapple()
    using Homebrew
    provides(Homebrew.HB, "hwloc", libhwloc, os=:Darwin)
end

if Sys.islinux()
    provides(AptGet, "libhwloc-dev", libhwloc, os=:Linux)
    provides(Yum, "hwloc-devel", libhwloc, os=:Linux)
end

if Sys.iswindows()
    using WinRPM
    provides(WinRPM.RPM, "hdf5", hdf5, os=:Windows)
end

# provides(Binaries,
#          URI("http://www.open-mpi.org/software/hwloc/v2.0/downloads/" *
#              "hwloc-win$(Base.Sys.WORD_SIZE)-build-2.0.1.zip"),
#          [libhwloc],
#          unpacked_dir="hwloc-win$(Base.Sys.WORD_SIZE)-build-2.0.1/bin",
#          os = :Windows)

# Build from source
provides(Sources,
         Dict(URI("http://www.open-mpi.org/software/hwloc/v2.0/downloads/" *
                  "hwloc-2.0.1.tar.gz") => libhwloc))
provides(BuildProcess,
         Dict(Autotools(libtarget="hwloc/libhwloc.la",
                        configure_options=["--without-x"]) => libhwloc))

@BinDeps.install Dict(:libhwloc => :libhwloc)
