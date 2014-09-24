#!/bin/bash
# Builds IEs4Linux script release
# Arguments:
#	$1 version number (optional, defaults to trunk)
#	$2 svn tag or trunk (optional, default is version number)

rm -rf workdir/ies4linux-script/
mkdir -p workdir/ies4linux-script/
cd workdir/ies4linux-script/

if [ "$1" != "" ]; then
	VERSION=$1
else
	VERSION="trunk"
fi
if [ "$2" = "" ]; then
	TAG=$VERSION
else
	TAG=$2
fi

echo Build version: $VERSION
echo SVN tag: $TAG
if [ "$TAG" = "trunk" ]; then
	VERSION="trunk-$(date +%Y%m%d)"
	svn co http://www.tatanka.com.br/svn/ies4linux/trunk ies4linux-script-$VERSION
else
	svn co http://www.tatanka.com.br/svn/ies4linux/tags/$TAG ies4linux-script-$VERSION
fi

find -name ".svn" -type d -exec rm -rf {} \; &> /dev/null
rm -rf ies4linux-script-$VERSION/platforms/mac/

tar zcvf ies4linux-script-$VERSION.tar.gz ies4linux-script-$VERSION
mv  ies4linux-script-$VERSION.tar.gz ../../dist
cd ../..
rm -rf workdir/ies4linux-script

