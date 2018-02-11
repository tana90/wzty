#!/bin/sh

SCRIPT_BASE=$(basename $(dirname $0))
SCRIPT_DIR=$(pwd)
if [[ ! -z $SCRIPT_BASE ]]
then
	SCRIPT_DIR=$SCRIPT_DIR/$SCRIPT_BASE
fi

BUILD_DIR=$SCRIPT_DIR
SOURCE_DIR=$SCRIPT_DIR/../
DEPLOY_SCRIPT=$SCRIPT_DIR/deploy.sh

STAGES=(beta release)
IPA_PATHS=(${BUILD_DIR}/Wzty-Beta.ipa ${BUILD_DIR}/Wzty-Release.ipa ${BUILD_DIR}/Wzty-AppStore.ipa)

set -e




iphonesdk=( $(xcodebuild -showsdks | grep iphoneos | awk '{print $4}') )

iphonesdk=${iphonesdk[@]:(-1)}
if [ -z $iphonesdk ]; then
	echo "No iphone sdk found!"
	exit 1
fi



pushd $(pwd)

echo "Building ..."

build()
{
	STAGE=$1
    IPA_PATH=$2
	SCHEME=$3
	EXPORT_OPTIONS_PLIST=$4
	
	echo $(pwd)

	xcodebuild archive -project ../Wzty.xcodeproj -scheme $SCHEME -archivePath $BUILD_DIR/Output/Wzty.xcarchive

	xcodebuild -exportArchive -archivePath $BUILD_DIR/Output/Wzty.xcarchive -exportPath $BUILD_DIR -exportOptionsPlist $EXPORT_OPTIONS_PLIST

	mv $BUILD_DIR/Wzty.ipa $IPA_PATH

	echo "Build Succeded. Application is ready to be deployed.\n"
}



build ${STAGES[0]} ${IPA_PATHS[0]} Wzty $BUILD_DIR/export_adhoc.plist
build ${STAGES[1]} ${IPA_PATHS[1]} Wzty $BUILD_DIR/export_adhoc.plist
build ${STAGES[1]} ${IPA_PATHS[2]} Wzty $BUILD_DIR/export_appStore.plist

echo "Build successful!"
popd

