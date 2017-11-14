#!/bin/sh

VERSION=$1

if [ -z $VERSION ]; then
	echo "Run: $0 version_number"
	exit 1
fi

SCRIPT_BASE=$(basename $(dirname $0))
SCRIPT_DIR=$(pwd)
if [[ ! -z $SCRIPT_BASE ]]
then
SCRIPT_DIR=$SCRIPT_DIR/$SCRIPT_BASE
fi

BUILD_DIR=$SCRIPT_DIR
SOURCE_DIR=$SCRIPT_DIR/../

/usr/libexec/PlistBuddy -c "Set CFBundleVersion ${VERSION}" $SOURCE_DIR/ParentalAdvisor/Info.plist
/usr/libexec/PlistBuddy -c "Set CFBundleVersion ${VERSION}" $SOURCE_DIR/ParentalAdvisorToday/Info.plist
