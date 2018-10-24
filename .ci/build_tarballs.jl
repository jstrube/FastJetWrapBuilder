# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "FastJetWrapBuilder"

# Collection of sources required to build Fjwbuilder
sources = [
    "https://github.com/jstrube/FastJetWrapBuilder.git" =>
    "0b7d7155f322559fea220d5dc95c09867d127d75",
]

# Bash recipe for building across all platforms
function getscript(version)
	shortversion = version[1:3]
	return """
	JlCxx_DIR=\$prefix/lib/cmake/JlCxx/
	cd \$WORKSPACE/srcdir
	mkdir build && cd build
	cmake -DCMAKE_INSTALL_PREFIX=\$prefix -DCMAKE_TOOLCHAIN_FILE=/opt/\$target/\$target.toolchain -DJulia_PREFIX=\$prefix/julia-$version ../FastJetWrapBuilder/
	VERBOSE=ON cmake --build . --config Release --target install
	"""
end
# Bash recipe for building across all platforms

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:x86_64, libc=:glibc),
    #Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc8))
]

#platforms = expand_gcc_versions(platforms)

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libfastjetwrap", :libfastjetwrap)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "https://github.com/JuliaInterop/libcxxwrap-julia/releases/download/v0.5.1/build_libcxxwrap-julia-1.0.v0.5.1.jl",
    "https://github.com/JuliaPackaging/JuliaBuilder/releases/download/1.0.0/build_Julia.v1.0.0.jl"
]

# Build the tarballs, and possibly a `build.jl` as well.
version_number = get(ENV, "TRAVIS_TAG", "")
if version_number == ""
    version_number = "v0.99"
end
build_tarballs(ARGS, name, VersionNumber(version_number), sources, getscript("1.0.0"), platforms, products, dependencies)

