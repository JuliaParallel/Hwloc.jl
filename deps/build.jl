using BinDeps

using Compat
import Compat.Sys

@BinDeps.setup

libhwloc = library_dependency("libhwloc", aliases=["libhwloc-5"])

# Note: We need hwloc 1.x, we don't support hwloc 2.x yet

# Install via a package manager
@static if Sys.islinux()
    provides(AptGet, "libhwloc-dev", libhwloc)
    provides(Yum, "hwloc-devel", libhwloc)
end

@static if Sys.isapple()
    using Homebrew
    provides(Homebrew.HB, "hwloc", libhwloc)
end

provides(Binaries,
         URI("http://www.open-mpi.org/software/hwloc/v1.11/downloads/" *
             "hwloc-win$(Base.Sys.WORD_SIZE)-build-1.11.10.zip"),
         [libhwloc],
         unpacked_dir="hwloc-win$(Base.Sys.WORD_SIZE)-build-1.11.10/bin",
         os = :Windows)

# Build from source
provides(Sources,
         Dict(URI("http://www.open-mpi.org/software/hwloc/v1.11/downloads/" *
                  "hwloc-1.11.10.tar.gz") => libhwloc))
provides(BuildProcess,
         Dict(Autotools(libtarget="src/libhwloc.la",
                        configure_options=["--without-x"]) => libhwloc))

@BinDeps.install Dict(:libhwloc => :libhwloc)
