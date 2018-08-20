using BinDeps

@BinDeps.setup

libhwloc = library_dependency("libhwloc", aliases=["libhwloc-5"])

# Install via a package manager
@static if Sys.islinux()
    provides(AptGet, "libhwloc-dev", libhwloc)
    provides(Yum, "hwloc-devel", libhwloc)
end

@static if Sys.isapple()
    using Homebrew
    provides(Homebrew.HB, "hwloc", libhwloc)
end

#TODO provides(Binaries,
#TODO          URI("http://www.open-mpi.org/software/hwloc/v2.0/downloads/" *
#TODO              "hwloc-win$(Base.Sys.WORD_SIZE)-build-2.0.1.zip"),
#TODO          [libhwloc],
#TODO          unpacked_dir="hwloc-win$(Base.Sys.WORD_SIZE)-build-2.0.1/bin",
#TODO          os = :Windows)

# Build from source
provides(Sources,
         Dict(URI("http://www.open-mpi.org/software/hwloc/v2.0/downloads/" *
                  "hwloc-2.0.1.tar.gz") => libhwloc))
provides(BuildProcess,
         Dict(Autotools(libtarget="hwloc/libhwloc.la",
                        configure_options=["--without-x"]) => libhwloc))

@BinDeps.install Dict(:libhwloc => :libhwloc)
