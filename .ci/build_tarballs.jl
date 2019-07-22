# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "FastJetWrapBuilder"

# Collection of sources required to build Fjwbuilder
sources = [
	   "FastJetWrapBuilder"
]

# Bash recipe for building across all platforms
function getscript(version)
	shortversion = version[1:3]
	return """
	JlCxx_DIR=\${prefix}/lib/cmake/JlCxx/
	cd \${WORKSPACE}/srcdir/
	mkdir build && cd build
	cmake -DCMAKE_INSTALL_PREFIX=\${prefix} -DCMAKE_TOOLCHAIN_FILE=/opt/\$target/\$target.toolchain -DCMAKE_FIND_ROOT_PATH=\${prefix} -DJulia_PREFIX=\${prefix} ..
	VERBOSE=OFF cmake --build . --config Release --target install
	"""
end
# Bash recipe for building across all platforms

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc7, :cxx11)),
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc8, :cxx11)),
    MacOS(:x86_64, compiler_abi=CompilerABI(:gcc7)),
    MacOS(:x86_64, compiler_abi=CompilerABI(:gcc8)),
]

#platforms = expand_gcc_versions(platforms)

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libfastjetwrap", :libfastjetwrap)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "https://github.com/JuliaInterop/libcxxwrap-julia/releases/download/v0.5.3/build_libcxxwrap-julia-1.0.v0.5.3.jl",
    "https://github.com/JuliaPackaging/JuliaBuilder/releases/download/v1.0.0-2/build_Julia.v1.0.0.jl",
#    "https://github.com/jstrube/FastJetBuilder/releases/download/v3.3.3/build_FastJetBuilder.v3.3.3.jl"
]

# Build the tarballs, and possibly a `build.jl` as well.
version_number = get(ENV, "TRAVIS_TAG", "")
if version_number == ""
    version_number = "v0.99"
end
build_tarballs(ARGS, name, VersionNumber(version_number), sources, getscript("1.0.0"), platforms, products, dependencies)

