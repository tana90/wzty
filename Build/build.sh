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

STAGES=(release)
IPA_PATHS=(${BUILD_DIR}/Parental-Release.ipa ${BUILD_DIR}/Parental-AppStore.ipa)

set -e

# create a list, multiple skds may be available
iphonesdk=( $(xcodebuild -showsdks | grep iphoneos | awk '{print $4}') )
# use the latest sdk
iphonesdk=${iphonesdk[@]:(-1)}
if [ -z $iphonesdk ]; then
	echo "No iphone sdk found!"
	exit 1
fi

################## BUILDING #########################

pushd $(pwd)

echo "Building ..."

build()
{
	STAGE=$1
    IPA_PATH=$2
	SCHEME=$3
	EXPORT_OPTIONS_PLIST=$4
	
	echo $(pwd)
	
#./build/prepare-stage.sh $STAGE
	
#   rm $IPA_PATH || true
	#xcodebuild -project ParentalAdvisor.xcodeproj -scheme $SCHEME -configuration Release -sdk $iphonesdk TARGET_BUILD_DIR=$BUILD_DIR/tmp TARGET_TEMP_DIR=$BUILD_DIR/products/intermediates DEPLOYMENT_LOCATION=YES DSTROOT=../Build DWARF_DSYM_FOLDER_PATH=../Build build

	xcodebuild archive -project ParentalAdvisor.xcodeproj -scheme $SCHEME -archivePath $BUILD_DIR/Applications/Parental.xcarchive

	xcodebuild -exportArchive -archivePath $BUILD_DIR/Applications/Parental.xcarchive -exportPath $BUILD_DIR -exportOptionsPlist $EXPORT_OPTIONS_PLIST

	mv $BUILD_DIR/ParentalAdvisor.ipa $IPA_PATH

	echo "Build Succeded. Application is ready to be deployed.\n"
}

extract_texts()
{
	xcodebuild -exportLocalizations -localizationPath $SOURCE_DIR/localization/ -project ParentalAdvisor.xcodeproj -exportLanguage en
}

#build beta
build ${STAGES[0]} ${IPA_PATHS[0]} ParentalAdvisor $BUILD_DIR/export_adhoc.plist
#build release
build ${STAGES[1]} ${IPA_PATHS[1]} ParentalAdvisor $BUILD_DIR/export_adhoc.plist
#bulid AppStore
build ${STAGES[1]} ${IPA_PATHS[2]} ParentalAdvisor $BUILD_DIR/export_appStore.plist

echo "Build successful. Ready to be deployed!"

#rm -r $SOURCE_DIR/localization/*
#texts=$(extract_texts)

popd

################## DEPLOY #########################

if [ "$#" = 1 ] && [ "$1" = "-deploy" ]; then
    $DEPLOY_SCRIPT -deployToPdfs
fi

