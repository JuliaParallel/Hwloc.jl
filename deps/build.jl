using BinDeps, Compat
@BinDeps.setup

libhwloc = library_dependency("libhwloc", aliases=["libhwloc-5"])

# Install via a package manager
@static if is_linux()
    provides(AptGet, "libhwloc-dev", libhwloc)
    provides(Yum, "hwloc-devel", libhwloc)
end

@static if is_apple()
    using Homebrew
    provides(Homebrew.HB, "homebrew/science/hwloc", libhwloc)
end

provides(Binaries,
         URI("http://www.open-mpi.org/software/hwloc/" *
             "v1.11/downloads/hwloc-win$(Sys.WORD_SIZE)-build-1.11.3.zip"),
         [libhwloc],
         unpacked_dir="hwloc-win$(Sys.WORD_SIZE)-build-1.11.3/bin",
         os = :Windows)

# Build from source
provides(Sources,
         @compat Dict(URI("http://www.open-mpi.org/software/hwloc/" *
                          "v1.11/downloads/hwloc-1.11.3.tar.gz") =>
                      libhwloc))
provides(BuildProcess,
         @compat Dict(Autotools(libtarget="src/libhwloc.la",
                                configure_options=["--without-x"]) => libhwloc))

@compat @BinDeps.install Dict(:libhwloc => :libhwloc)
