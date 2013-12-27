#!/usr/bin/env bash

# Load common functions
source `dirname $0`/common.cfg

PRODUCT_DIR=$OUTPUT_DIR/Build/Products/$CONFIGURATION-iphoneos 

if [ ! -d $ARTIFACT_DIR ]; then
     mkdir $ARTIFACT_DIR       
else                             
     rm -rf $ARTIFACT_DIR/*
fi

IPA_OUT=${SCHEME// /_}

message "Building IPA for $SCHEME"
COMMAND="xcrun -sdk iphoneos PackageApplication -v \"$PRODUCT_DIR/$SCHEME.app\" -o \"$ARTIFACT_DIR/$IPA_OUT.ipa\""
if ! $VERBOSE; then COMMAND+=" > /dev/null"; fi
(IFS=$'\n'; eval $COMMAND)

message "Packaging artifacts" 
pushdSilent $PRODUCT_DIR
for filename in *.app; do 
     NAME=${filename/.app/}
     (IFS=$'\n'; zip -qry "$ARTIFACT_DIR/$NAME-$CONFIGURATION.zip" $filename)
done
for filename in *.app.dSYM; do                      
     NAME=${filename/.app.dSYM/}              
     (IFS=$'\n'; zip -qry "$ARTIFACT_DIR/dSYM-$NAME-$CONFIGURATION" $filename)
done                                       
popdSilent

message "Packaging for distribution"
mkdir $ARTIFACT_DIR/Distribution
CMD="`dirname $0`/ipasign.sh \"$ARTIFACT_DIR/${IPA_OUT}.ipa\" -p ~/Library/MobileDevice/Provisioning\ Profiles/${IPA_OUT}_Enterprise_Distribution.mobileprovision -c \"iPhone Distribution: Badoo Limited\" -o $ARTIFACT_DIR/Distribution/${IPA_OUT}_InHouse.ipa"
echo $CMD
eval $CMD



