#!/bin/sh

STAGE=$1
SCRIPT_DIR=$(pwd)

if [ -z $STAGE ]; then
	echo "Run: $0 alpha/beta/release"
	exit 1
fi

#echo "running prepare-stage.sh in ${SCRIPT_DIR}"

#mv $SCRIPT_DIR/BitdefenderCentral/Info.plist Info-tmp.plist
#echo "done mv"
#cp $SCRIPT_DIR/BitdefenderCentral/Info_$STAGE.plist $SCRIPT_DIR/BitdefenderCentral/Info.plist
#echo "done cp"

#/usr/libexec/PlistBuddy -c "Merge Info-tmp.plist" $SCRIPT_DIR/BitdefenderCentral/Info.plist
#/usr/libexec/PlistBuddy -c "Set CFBundleName '\${PRODUCT_NAME}'-${STAGE}" $SCRIPT_DIR/BitdefenderCentral/Info.plist

#if [ “${STAGE}” = “release” ]; then
#	/usr/libexec/PlistBuddy -c "Set CFBundleDisplayName 'Bitdefender Central'" $SCRIPT_DIR/BitdefenderCentral/Info.plist
#else
#	/usr/libexec/PlistBuddy -c "Set CFBundleDisplayName '\${PRODUCT_NAME}'-${STAGE}" $SCRIPT_DIR/BitdefenderCentral/Info.plist
#fi

#rm Info-tmp.plist
