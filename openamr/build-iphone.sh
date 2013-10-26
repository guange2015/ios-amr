#!/bin/sh

set -xe

PATH=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin:$PATH
SDK=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS6.1.sdk
DEST=/tmp/opencore-amr-iphone

ARCHS="armv7 armv7s"
LIBS="libopencore-amrnb.a libopencore-amrwb.a"

for arch in $ARCHS; do
	case $arch in
	arm*)
		CC="gcc -arch $arch --sysroot=$SDK" CXX="g++ -arch $arch --sysroot=$SDK" \
		LDFLAGS="-Wl,-syslibroot,$SDK" ./configure \
		--host=arm-apple-darwin --prefix=$DEST \
		--disable-shared --enable-gcc-armv5
		;;
	*)
		CC="gcc -arch $arch" CXX="g++ -arch $arch" \
		./configure \
		--prefix=$DEST \
		--disable-shared
		;;
	esac
	make -j3
	make install
	make clean
	for i in $LIBS; do
		mv $DEST/lib/$i $DEST/lib/$i.$arch
	done
done

for i in $LIBS; do
	input=""
	for arch in $ARCHS; do
		input="$input $DEST/lib/$i.$arch"
	done
	lipo -create -output $DEST/lib/$i $input
done

