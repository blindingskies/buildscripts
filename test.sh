#!/usr/bin/env bash

source `dirname $0`/common.cfg      

unlockKeychain

#COMMAND="xcodebuild test -workspace $PROJECT_DIR/$PROJECT_NAME.xcworkspace -sdk iphonesimulator -configuration Debug -scheme \"$TEST_SCHEME\" OTHER_CODE_SIGN_FLAGS=\"--keychain ${KEYCHAIN}\""

COMMAND="xcodebuild test -workspace $PROJECT_DIR/$PROJECT_NAME.xcworkspace -sdk iphonesimulator -configuration Debug -scheme \"$TEST_SCHEME\"

# Delete the .gcda files created by enabling Test Coverage reports in XCode. These can cause "invalid magic number" errors on subsequent builds
message "Pre-test cleanup"
GET_BUILD_SETTINGS="$COMMAND -showBuildSettings"
BUILD_SETTINGS=`eval ${GET_BUILD_SETTINGS}`
RESULT_COUNT=`echo "$BUILD_SETTINGS" | awk '/CURRENT_ARCH = /{++c} END {print c;}'`
for i in $(seq 1 $RESULT_COUNT); do
	CURRENT_ARCH=`echo "$BUILD_SETTINGS" | awk -v i=$i '/CURRENT_ARCH = /{l++; if (l==i) print $3;}'`
	OBJ_DIR=`echo "$BUILD_SETTINGS" | awk -v i=$i '/OBJECT_FILE_DIR_normal = /{l++; if (l==i) print $3;}'`
	echo "Deleting *.gcda from $OBJ_DIR/$CURRENT_ARCH"
	pushdSilent $OBJ_DIR/$CURRENT_ARCH && rm ./*.gcda && popdSilent
done

message "Running tests (sdk=iphonesimulator, scheme=$TEST_SCHEME)"
TEST_OUTPUT="$LOG_DIR/testOutput.log"
mkdir -p `dirname $TEST_OUTPUT`
if $VERBOSE; then 
    COMMAND+=" 2>&1| tee $TEST_OUTPUT"
else
    # cat is used on purpose, otherwise lines are jumbled by TEST SUCCEEDED message
    COMMAND+=" 2>&1| cat > $TEST_OUTPUT" 
fi
eval $COMMAND

# Don't want to exit on grep failure"
set +e
 
# Print summary
RESULTS=`cat $TEST_OUTPUT | grep -i "executed" | tail -n 1`
cat $TEST_OUTPUT | grep " failed \|TEST FAILED"
if didFail; then 
    printWithColour " :)  " $COL_GREEN
	echo -e "$RESULTS"
else
    printWithColour " :(  " $COL_RED
	echo -e "$RESULTS"
	exit 1
fi

set -e
