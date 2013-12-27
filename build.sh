#!/usr/bin/env bash

# Load common functions
source `dirname $0`/common.cfg
source `dirname $0`/build-options.cfg

# Run
unlockKeychain
message "Running xcodebuild"

#COMMAND="xcodebuild -workspace $PROJECT_DIR/$PROJECT_NAME.xcworkspace -sdk iphoneos -configuration $CONFIGURATION -scheme '$SCHEME' -derivedDataPath $OUTPUT_DIR OTHER_CODE_SIGN_FLAGS=\"--keychain ${KEYCHAIN}\""
COMMAND="xcodebuild -workspace $PROJECT_DIR/$PROJECT_NAME.xcworkspace -sdk iphoneos -configuration $CONFIGURATION -scheme '$SCHEME' -derivedDataPath $OUTPUT_DIR"
BUILD_OUTPUT="$LOG_DIR/buildOutput.log"                                                                                       
mkdir -p `dirname $BUILD_OUTPUT`
if $VERBOSE; then                                                                                                           
    EXEC="$COMMAND 2>&1| tee $BUILD_OUTPUT"                                                                                      
else                                                                                                                        
    EXEC="$COMMAND 2>&1| xcpretty > $BUILD_OUTPUT"     
fi                                     

set +e
set -o pipefail
eval $EXEC
if didFail; then
	cat $BUILD_OUTPUT | grep -A 5 "error:"
	printWithColour " :(  " $COL_RED; echo "Build failed" 
	echo -e "\n See $BUILD_OUTPUT for full log."
    exit 1
fi
set -e
set +o pipefail

printWithColour " :)  " $COL_GREEN; echo "Build successful"



