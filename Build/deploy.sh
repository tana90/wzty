#!/bin/sh

#  deploy.sh
#  
#
#

SCRIPT_BASE=$(basename $(dirname $0))
SCRIPT_DIR=$(pwd)
if [[ ! -z $SCRIPT_BASE ]]
then
    SCRIPT_DIR=$SCRIPT_DIR/$SCRIPT_BASE
fi

SOURCE_DIR=$SCRIPT_DIR/../

IPA_BETA=$SCRIPT_DIR/Parental-Beta.ipa
IPA_RELEASE=$SCRIPT_DIR/Parental-Release.ipa
IPA_APPSTORE=$SCRIPT_DIR/Parental-AppStore.ipa


CRASHLYTICS_APIKEY=df3bbc554e63e8e54fc1512b0773d8d6c8e8806a
CRASHLYTICS_BUILDSECRET=9594f7dcf79a753c1bdd2efdf8c373cb94d6d95f61c8bf5ef681ce08970f66ed

DISTRIBUTION_EMAILS=cstan@bitdefender.com,tana@bitdefender.com,lholban@bitdefender.com
DISTRIBUTION_GROUPS=parental-ios

#
PDFS01="pdfs01.bitdefender.biz/Box/Modules/ParentalAdvisor/ios/Intermediary"

# Read app version
echo "/usr/libexec/PlistBuddy -c Print CFBundleVersion $SOURCE_DIR/ParentalAdvisor/Info.plist"
BUNDLE_SHORT_VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" $SOURCE_DIR/ParentalAdvisor/Info.plist)
BUNDLE_VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" $SOURCE_DIR/ParentalAdvisor/Info.plist)
VERSION="$BUNDLE_SHORT_VERSION.$BUNDLE_VERSION"

set -e

mount_share()
{
    SHARE_TYPE=$1
    # devbin
    LOCATION_NAME=$(echo $2 | awk -F'/' '{print $1}')
    # Components/BitDefender/Box
    LOCATION_PATH=$(echo $2 | awk -F'/' '{for (i=2; i<NF; i++) printf $i "/"; print $NF}')
    LOCATION_IP=$(host $LOCATION_NAME | grep 'has address' | awk '{print $4}')
    MOUNT_POINT=$3

    if [[ -z $LOCATION_IP ]]; then
        echo "Error: Cannot resolve host name: "$LOCATION_NAME
        exit 1
    fi

    # check if it's already mounted
    IS_MOUNTED_WITH_IP=true
    # check is mounted the exact node (ie. pdfs01.bitdefender.biz/Nimbus/push != pdfs01.bitdefender.biz/Nimbus)
    MOUNTED_LOCATION=( $(mount | grep -e ".*$LOCATION_IP/$LOCATION_PATH .*" | awk '{print $1}' | awk -F'@' '{print $2}') )
    if [[ -z $MOUNTED_LOCATION ]]; then
        # check is mounted using host name
        MOUNTED_LOCATION=( $(mount | grep -e ".*$LOCATION_NAME/$LOCATION_PATH .*" | awk '{print $1}' | awk -F'@' '{print $2}') )
        IS_MOUNTED_WITH_IP=false
    fi

    if [[ ! -z $MOUNTED_LOCATION ]]; then
        mount_host=$LOCATION_NAME
        if [ $IS_MOUNTED_WITH_IP = true ]; then
            mount_host=$LOCATION_IP
        fi
        MOUNT_POINT=$(mount | grep -e ".*$mount_host/$LOCATION_PATH .*" | awk '{print $3}')
    else # mount
        index=0
        dir=$MOUNT_POINT
        while [[ -d $dir ]]; do
            lst=$(ls $dir)
            if [[ -z $lst ]]; then
                break;
            fi

            index=`expr $index + 1`
            dir="$MOUNT_POINT""_$index"
        done

        MOUNT_POINT=$dir
        if [ ! -d $MOUNT_POINT ]; then
            mkdir -p $MOUNT_POINT
        fi

        authstr=""
        user="compile-mac"
        password="M@cComp!l3P@ssw0rd"
		authstr=$user:$(python -c "import urllib; print urllib.quote_plus('''$password''')")"@"

        MOUNT_OPT=$SHARE_TYPE
        if [[ $MOUNT_OPT = smb ]]; then
            MOUNT_OPT=smbfs
        fi
        mount -t $MOUNT_OPT $SHARE_TYPE://$authstr$LOCATION_NAME/$LOCATION_PATH $MOUNT_POINT

        err=$?
        if [[ $err != 0 && $err != 64 ]]; then
            echo "Error: Failed to mount "$LOCATION_IP "Error = $err"
            exit $err
        fi
    fi

    echo $MOUNT_POINT
}

################## DEPLOY #########################

deploy_to_crashlytics()
{
	IPA_PATH=$1
	API_KEY=$2
	BUILD_SECRET=$3

	security unlock-keychain -p 'M@cComp!l3P@ssw0rd'
	./Crashlytics.framework/submit $API_KEY $BUILD_SECRET -ipaPath $IPA_PATH -emails $DISTRIBUTION_EMAILS -notesPath commits.txt -groupAliases $DISTRIBUTION_GROUPS -notifications YES
}

deploy_to_pdfs()
{
    IPA_BETA=$1
	IPA_RELEASE=$2
	IPA_APPSTORE=$3

    echo "Mounting $PDFS01 ..."

    PDFS01_MP=$(mount_share smb $PDFS01 "/tmp/pdfs01_parental_smbshare")
    err=$?
    if [[ $err != 0 || -z $PDFS01_MP ]]; then
        echo "Failure while mounting $BOXDEVBIN: $BOXDEVBIN_MP, error=$err"

        if [[ $err == 77 ]]; then
            echo "Authentication failure. Please provide username and password"
        fi

        exit $err
    fi

    mkdir $PDFS01_MP/$VERSION | true

#    cp $IPA_ALPHA $PDFS01_MP/$VERSION
    cp $IPA_BETA $PDFS01_MP/$VERSION
	cp $IPA_RELEASE $PDFS01_MP/$VERSION
	cp $IPA_APPSTORE $PDFS01_MP/$VERSION

#cp $SOURCE_DIR/localization/en.xliff $PDFS01_MP/$VERSION/en.xlf

    umount $PDFS01_MP
}

#echo "Deploying to Crashlytics ..."
deploy_to_crashlytics $IPA_RELEASE $CRASHLYTICS_APIKEY $CRASHLYTICS_BUILDSECRET


if [ "$#" = 1 ] && [ "$1" = "-deployToPdfs" ]; then
    echo "Deploying to $PDFS01 ..."
    deploy_to_pdfs $IPA_BETA $IPA_RELEASE $IPA_APPSTORE
fi
