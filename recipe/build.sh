#! /bin/bash

set -ex

export PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig:$PREFIX/share/pkgconfig"

configure_args=(
    --prefix=$PREFIX
    --disable-Bsymbolic
)

if [ -n "$OSX_ARCH" ] ; then
    export LDFLAGS="$LDFLAGS -Wl,-rpath,$PREFIX/lib"
fi

# remove any libtool files of packages we depend on:
find $PREFIX -name '*.la' -delete

./configure "${configure_args[@]}" || { cat config.log ; exit 1 ; }
make -j$NJOBS
make install

cd $PREFIX
find . '(' -name '*.la' -o -name '*.a' ')' -delete
rm -rf share/gtk-doc
