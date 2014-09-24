#!/bin/bash
# Builds IEs4Mac script release
# Arguments:
#	$1 version number (optional, defaults to trunk)
#	$2 svn tag or trunk (optional, default is version number)

rm -rf workdir/ies4mac-script/
mkdir -p workdir/ies4mac-script/
cd workdir/ies4mac-script/

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
	svn co http://www.tatanka.com.br/svn/ies4linux/trunk ies4mac-script-$VERSION
else
	svn co http://www.tatanka.com.br/svn/ies4linux/tags/$TAG ies4mac-script-$VERSION
fi

find -name ".svn" -type d -exec rm -rf {} \; &> /dev/null
rm -rf ies4mac-script-$VERSION/platforms/linux/
mv ies4mac-script-$VERSION/ies4linux ies4mac-script-$VERSION/ies4mac

zip -r ies4mac-script-$VERSION.zip ies4mac-script-$VERSION
mv  ies4mac-script-$VERSION.zip ../../dist
cd ../..
rm -rf workdir/ies4mac-script

