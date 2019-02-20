#!/bin/sh

#  build-react-app.sh
#  SubCalc
#
#  Created by Alexander Celeste on 2/13/19.
#  Copyright © 2019 Tenseg LLC.

# input files:
#	* $(TARGET_BUILD_DIR)/$(INFOPLIST_PATH)

# so that we error out when individual commands have errors
set -e

# check for node
if ! which node > /dev/null; then
	echo "error: Node.js is not installed. Run: brew install node."
	exit 1
fi

# check for yarn
if ! which yarn > /dev/null; then
	echo "error: Yarn is not installed. Run: brew install yarn."
	exit 1
fi

# check for the submodule
if [ ! "$(ls -A $SRCROOT/React)" ]; then
	echo "error: React submodule not set up. Please run git submodule update --init --recursive, followed by yarn in the submodule's folder."
	exit 1
fi

# save version and debug info to the environment
appInfo="${CONFIGURATION_BUILD_DIR}/${WRAPPER_NAME}/Info.plist"
export REACT_APP_IOS_VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$appInfo")
export REACT_APP_IOS_BUILD=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$appInfo")
export CI=true
if [ "${CONFIGURATION}" = "Debug" ]; then
	export REACT_APP_IOS_DEBUG="yes"
fi

# build the react app
/usr/local/bin/yarn --cwd "/$SRCROOT/React" run build

# move the built react app into the iOS app bundle
mkdir -p "${CONFIGURATION_BUILD_DIR}/${WRAPPER_NAME}/react"
rm -rf "${CONFIGURATION_BUILD_DIR}/${WRAPPER_NAME}/react/"*
MOVE="${CONFIGURATION_BUILD_DIR}/${WRAPPER_NAME}/react/"
mv "$SRCROOT/React/build/"* "${CONFIGURATION_BUILD_DIR}/${WRAPPER_NAME}/react/"
rm -rf "$SRCROOT/React/build/"
