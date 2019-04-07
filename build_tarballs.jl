using BinaryBuilder

# These are the platforms built inside the wizard
platforms = [
    BinaryProvider.Linux(:i686, :glibc),
  BinaryProvider.Linux(:x86_64, :glibc),
  BinaryProvider.Linux(:aarch64, :glibc),
  BinaryProvider.Linux(:armv7l, :glibc),
  BinaryProvider.Linux(:powerpc64le, :glibc),
  BinaryProvider.MacOS(),
  BinaryProvider.Windows(:i686),
  BinaryProvider.Windows(:x86_64)
]


# If the user passed in a platform (or a few, comma-separated) on the
# command-line, use that instead of our default platforms
if length(ARGS) > 0
    platforms = platform_key.(split(ARGS[1], ","))
end
info("Building for $(join(triplet.(platforms), ", "))")

# Collection of sources required to build readstat
sources = [
    "https://github.com/WizardMac/ReadStat.git" =>
    "f6bfe845689abc6f251acedd1c873cc86e1fdd5c",
]

script = raw"""
cd $WORKSPACE/srcdir
cd ReadStat/
./autogen.sh 
./configure --prefix=/ --host=$target

if [ $target = "x86_64-w64-mingw32" ] || [ $target = "i686-w64-mingw32" ]; then
./configure --prefix=/ --host=$target CFLAGS="-I$DESTDIR/include" LDFLAGS="-L$DESTDIR/lib"
else
./configure --prefix=/ --host=$target
fi

make -j4
make install

"""

products = prefix -> [
    ExecutableProduct(prefix,"readstat"),
    LibraryProduct(prefix,"libreadstat")
]

dependencies = [
"https://raw.githubusercontent.com/Keno/IConvBuilder7/ca7e6a82f61cdb1c5ae53bdc94702488384435db/build.jl"]

# Build the given platforms using the given sources
autobuild(pwd(), "readstat", platforms, sources, script, products, dependencies=dependencies)

