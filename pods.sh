#!/usr/bin/env bash

source `dirname $0`/common.cfg      

if [ -f $PODS_ROOT/Manifest.lock ]; then
	set +e
	diff "${PODS_ROOT}/../Podfile.lock" "${PODS_ROOT}/Manifest.lock" > /dev/null
	if didFail; then
		message "Updating Cocoapods"
		COMMAND="pod update"
	else
		message "Cocoapods already installed and up-to-date!"
		exit 0
	fi
	set -e
else
	message "Installing Cocoapods"
	COMMAND="pod install"
fi

if $VERBOSE; then 
    COMMAND="$COMMAND --verbose"
else
    COMMAND="$COMMAND --silent"
fi
cd_and_execute "$PROJECT_DIR" "$COMMAND"

