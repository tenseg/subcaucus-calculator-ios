#!/bin/sh

#  build-react-app.sh
#  SubCalc
#
#  Created by Alexander Celeste on 2/13/19.
#  Copyright © 2019 Tenseg. All rights reserved.

# check for npm
if ! which npm > /dev/null; then
	echo "error: Node.js is not installed. Visit https://nodejs.org/ to learn more."
	exit 1
fi

# save version and debug info to the environment
appInfo="${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/Info.plist"
export REACT_APP_IOS_VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$appInfo")
export REACT_APP_IOS_BUILD=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$appInfo")
if [ "${CONFIGURATION}" = "Debug" ]; then
	export REACT_APP_IOS_DEBUG="yes"
fi

# build the react app
/usr/local/bin/npm run --prefix $SRCROOT/React build

# move the built react app into the iOS app bundle
mkdir -p ${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/react
rm -r ${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/react/*
mv $SRCROOT/React/build/* ${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/react
rm -r $SRCROOT/React/build/
