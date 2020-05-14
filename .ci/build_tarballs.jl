# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder
using Pkg

name = "FastJet_Julia_Wrapper"
version = v"0.7.2"

# Collection of sources required to build Fjwbuilder
sources = [
	DirectorySource("FastJet_Julia_Wrapper"),
	ArchiveSource("https://julialang-s3.julialang.org/bin/linux/x64/1.3/julia-1.3.1-linux-x86_64.tar.gz", "faa707c8343780a6fe5eaf13490355e8190acf8e2c189b9e7ecbddb0fa2643ad"; unpack_target="julia-x86_64-linux-gnu"),
]

# Bash recipe for building across all platforms
script = raw"""
case "$target" in
	arm-linux-gnueabihf|x86_64-linux-gnu)
        Julia_PREFIX=${WORKSPACE}/srcdir/julia-$target/julia-1.3.1
        ;;
    x86_64-apple-darwin14|x86_64-w64-mingw32)
        Julia_PREFIX=${WORKSPACE}/srcdir/julia-$target/juliabin
        ;;
esac
cd ${WORKSPACE}/srcdir
mkdir build && cd build
cmake -DJulia_PREFIX=${Julia_PREFIX} -DCMAKE_INSTALL_PREFIX=${prefix} -DCMAKE_FIND_ROOT_PATH=${prefix} -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TARGET_TOOLCHAIN} -DCMAKE_BUILD_TYPE=Release ..
VERBOSE=ON cmake --build . --config Release --target install
install_license $WORKSPACE/srcdir/LICENSE.md
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = Platform[
    Linux(:x86_64, libc=:glibc)
]
platforms = expand_cxxstring_abis(platforms)

# The products that we will ensure are always built
products = [
    LibraryProduct("libfastjetwrap", :libfastjetwrap)
]

# Dependencies that must be installed before this package can be built
dependencies = [
	Dependency("libcxxwrap_julia_jll"),
	Dependency("FastJet_jll")
	# Dependency(PackageSpec(;name="FastJet_jll", url="https://github.com/jstrube/FastJet_jll.jl"))
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies; preferred_gcc_version=v"9")
