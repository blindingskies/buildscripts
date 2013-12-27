#!/usr/bin/env bash

source `dirname $0`/common.cfg
source `dirname $0`/build-options.cfg

#COMMAND="xcodebuild test -workspace $PROJECT_DIR/$PROJECT_NAME.xcworkspace -sdk iphonesimulator -configuration Debug -scheme \"$TEST_SCHEME\" OTHER_CODE_SIGN_FLAGS=\"--keychain ${KEYCHAIN}\""

COMMAND="xcodebuild test -workspace "$PROJECT_DIR"/$PROJECT_NAME.xcworkspace -sdk iphonesimulator -configuration Debug -scheme \"$TEST_SCHEME\""

message "Running tests (sdk=iphonesimulator, scheme=$TEST_SCHEME)"
TEST_OUTPUT="$LOG_DIR/testOutput.log"
mkdir -p "`dirname "$TEST_OUTPUT"`"

if $VERBOSE; then 
    COMMAND+=" 2>&1| tee $TEST_OUTPUT"
else
    # cat is used on purpose, otherwise lines are jumbled by TEST SUCCEEDED message
    COMMAND+=" 2>&1| xcpretty | cat > $TEST_OUTPUT" 
fi
eval $COMMAND

# Don't want to exit on grep failure"
set +e
 
# Print summary
RESULTS=`cat $TEST_OUTPUT | grep -i "executed" | tail -n 1`
cat "$TEST_OUTPUT" | grep " failed \|TEST FAILED"
if didFail; then 
    printWithColour " :)  " $COL_GREEN
	echo -e "$RESULTS"
else
    printWithColour " :(  " $COL_RED
	echo -e "$RESULTS"
	exit 1
fi

set -e
