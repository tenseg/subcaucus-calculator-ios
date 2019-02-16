#!/bin/sh

#  save-git-count-as-buildnum.sh
#  SubCalc
#
#  Created by Alexander Celeste on 2/13/19.
#  Copyright © 2019 Tenseg. All rights reserved.

# input files:
#	* $(TARGET_BUILD_DIR)/$(INFOPLIST_PATH)
#	* ${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}

#  Run this script after the 'Copy Bundle Resources' build phase
#  It will compute the git commit number and write that to the CFBundleVersion of the target's built Info.plist
#  From http://tgoode.com/2014/06/05/sensible-way-increment-bundle-version-cfbundleversion-xcode/#code

branch=${1:-'master'}
buildNumber=$(expr $(git rev-list $branch --count) - $(git rev-list HEAD..$branch --count))

echo "Updating build number to $buildNumber using branch '$branch' in production plist."
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"

debugInfoPlistPath = "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}.dSYM/Contents/Info.plist"
if [ -f "${debugInfoPlistPath}" ]; then
    echo "Updating build number to $buildNumber using branch '$branch' in debug dSYM plist."
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "${debugInfoPlistPath}"
fi
