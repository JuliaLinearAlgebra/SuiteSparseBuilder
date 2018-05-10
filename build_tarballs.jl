using BinaryBuilder

# Collection of sources required to build SuiteSparse
sources = [
    "http://faculty.cse.tamu.edu/davis/SuiteSparse/SuiteSparse-5.2.0.tar.gz" =>
    "3c46c035ea8217649958a0f73360e825b0c9dcca4e32a9349d2c7678c0d48813",

]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/SuiteSparse

UNAME=`uname`
LDFLAGS="-L$prefix/lib"

if [[ ${UNAME} == MSYS_NT-6.3 ]]; then
    UNAME="Windows"
    LDFLAGS="-L$prefix/lib -shared"
    CFOPENMP=
fi

if [[ ${nbits} == 64 ]]; then
    BLAS="-lopenblas64_"
    LAPACK="-lopenblas64_"
    UMFPACK_CONFIG="-DSUN64 -DLONGBLAS='long long'"
    CHOLMOD_CONFIG="-DSUN64 -DLONGBLAS='long long' -DNPARTITION"
    SPQR_CONFIG="-DSUN64 -DLONGBLAS='long long'"
else
    BLAS="-lopenblas"
    LAPACK="-lopenblas"
    UMFPACK_CONFIG=
    CHOLMOD_CONFIG="-DNPARTITION"
    SPQR_CONFIG=
fi

make -j -C SuiteSparse_config library INSTALL="$prefix" BLAS="$BLAS" LAPACK="$LAPACK" UMFPACK_CONFIG="$UMFPACK_CONFIG" CHOLMOD_CONFIG="$CHOLMOD_CONFIG" SPQR_CONFIG="$SPQR_CONFIG" UNAME="$UNAME" LDFLAGS="$LDFLAGS" CFOPENMP="$CFOPENMP" config

for proj in SuiteSparse_config AMD BTF CAMD CCOLAMD COLAMD CHOLMOD LDL KLU UMFPACK RBio SPQR; do
    make -j -C $proj library INSTALL="$prefix" BLAS="$BLAS" LAPACK="$LAPACK" UMFPACK_CONFIG="$UMFPACK_CONFIG" CHOLMOD_CONFIG="$CHOLMOD_CONFIG" SPQR_CONFIG="$SPQR_CONFIG" UNAME="$UNAME" LDFLAGS="$LDFLAGS" CFOPENMP="$CFOPENMP"
    make -j -C $proj install INSTALL="$prefix" BLAS="$BLAS" LAPACK="$LAPACK" UMFPACK_CONFIG="$UMFPACK_CONFIG" CHOLMOD_CONFIG="$CHOLMOD_CONFIG" SPQR_CONFIG="$SPQR_CONFIG" UNAME="$UNAME" LDFLAGS="$LDFLAGS" CFOPENMP="$CFOPENMP"
echo make "$MAKE_OPTS"
done

"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    BinaryProvider.Windows(:i686, :blank_libc, :blank_abi),
    BinaryProvider.Windows(:x86_64, :blank_libc, :blank_abi),
    BinaryProvider.Linux(:x86_64, :glibc, :blank_abi),
    BinaryProvider.Linux(:i686, :glibc, :blank_abi),
    BinaryProvider.Linux(:aarch64, :glibc, :blank_abi),
    BinaryProvider.Linux(:armv7l, :glibc, :eabihf),
#    BinaryProvider.MacOS(:x86_64, :blank_libc, :blank_abi),
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libsuitesparseconfig", :suitesparseconfig),
    LibraryProduct(prefix, "libamd", :amd),
    LibraryProduct(prefix, "libbtf", :btf),
    LibraryProduct(prefix, "libcamd", :camd),
    LibraryProduct(prefix, "libccolamd", :ccolamd),
    LibraryProduct(prefix, "libcolamd", :colamd),
    LibraryProduct(prefix, "libcholmod", :cholmod),
    LibraryProduct(prefix, "libldl", :ldl),
    LibraryProduct(prefix, "libklu", :klu),
    LibraryProduct(prefix, "libumfpack", :umfpack),
    LibraryProduct(prefix, "librbio", :rbio),
    LibraryProduct(prefix, "libspqr", :spqr),
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "https://github.com/staticfloat/OpenBLASBuilder/releases/download/v0.2.20-6/build.jl"
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, "SuiteSparse", sources, script, platforms, products, dependencies)
