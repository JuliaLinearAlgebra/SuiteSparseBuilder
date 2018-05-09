using BinaryBuilder

# Collection of sources required to build SuiteSparse
sources = [
    "http://faculty.cse.tamu.edu/davis/SuiteSparse/SuiteSparse-5.2.0.tar.gz" =>
    "3c46c035ea8217649958a0f73360e825b0c9dcca4e32a9349d2c7678c0d48813",

]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd SuiteSparse/

UNAME=`uname`
if [[ ${UNAME} == MSYS_NT-6.3 ]]; then 
     UNAME="Windows"
fi

if [[ ${nbits} == 64 ]]; then
     make -j library UMFPACK_CONFIG="-DSUN64 -DLONGBLAS='long long'" CHOLMOD_CONFIG="-DSUN64 -DLONGBLAS='long long'" SPQR_CONFIG="-DSUN64 -DLONGBLAS='long long'"
     make -j install INSTALL=$prefix/lib BLAS="-L$prefix/lib -lopenblas64_" LAPACK="-L$prefix/lib -lopenblas64_" UMFPACK_CONFIG="-DSUN64 -DLONGBLAS='long long'" CHOLMOD_CONFIG="-DSUN64 -DLONGBLAS='long long'" SPQR_CONFIG="-DSUN64 -DLONGBLAS='long long'"
else
     make -j library UNAME=${UNAME}
     make -j install UNAME=${UNAME} INSTALL=$prefix/lib BLAS="-L$prefix/lib -lopenblas" LAPACK="-L$prefix/lib -lopenblas"
fi


"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
#    BinaryProvider.Windows(:i686, :blank_libc, :blank_abi),
    BinaryProvider.Linux(:x86_64, :glibc, :blank_abi),
    BinaryProvider.Linux(:i686, :glibc, :blank_abi),
    BinaryProvider.Linux(:aarch64, :glibc, :blank_abi),
    BinaryProvider.Linux(:armv7l, :glibc, :eabihf)
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libbtf", :btf),
    LibraryProduct(prefix, "librbio", :rbio),
    LibraryProduct(prefix, "libcxsparse", :cxsparse),
    LibraryProduct(prefix, "libldl", :ldl),
    LibraryProduct(prefix, "libmetis", :metis),
    LibraryProduct(prefix, "libklu", :klu),
    LibraryProduct(prefix, "libcolamd", :colamd),
    LibraryProduct(prefix, "libccolamd", :ccolamd),
    LibraryProduct(prefix, "libcamd", :camd),
    LibraryProduct(prefix, "libcholmod", :cholmod),
    LibraryProduct(prefix, "libsuitesparseconfig", :suitesparseconfig),
    LibraryProduct(prefix, "libumfpack", :umfpack),
    LibraryProduct(prefix, "libgraphblas", :graphblas),
    LibraryProduct(prefix, "libspqr", :spqr),
    LibraryProduct(prefix, "libamd", :amd)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "https://github.com/staticfloat/OpenBLASBuilder/releases/download/v0.2.20-6/build.jl"
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, "SuiteSparse", sources, script, platforms, products, dependencies)

