#!/bin/sh

#  save-git-count-as-buildnum.sh
#  SubCalc
#
#  Created by Alexander Celeste on 2/13/19.
#  Copyright © 2019 Tenseg LLC.

# input files:
#	* $(TARGET_BUILD_DIR)/$(INFOPLIST_PATH)
#	* ${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}.dSYM/Contents/Info.plist

#  Run this script after the 'Copy Bundle Resources' build phase
#  It will compute the git commit number and write that to the CFBundleVersion of the target's built Info.plist
#  From http://tgoode.com/2014/06/05/sensible-way-increment-bundle-version-cfbundleversion-xcode/#code

# so that we error out when individual commands have errors
set -e

# get the build number
branch=${1:-'main'}
buildNumber=$(expr $(git rev-list $branch --count) - $(git rev-list HEAD..$branch --count))

# write to the app bundle
echo "Updating build number to $buildNumber using branch '$branch' in production plist."
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"

# write to the dsym bundle if available
debugInfoPlistPath="${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}.dSYM/Contents/Info.plist"
if [ -f "${debugInfoPlistPath}" ]; then
    echo "Updating build number to $buildNumber using branch '$branch' in debug dSYM plist."
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "${debugInfoPlistPath}"
fi
