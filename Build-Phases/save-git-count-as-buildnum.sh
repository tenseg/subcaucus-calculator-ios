#!/bin/sh

#  save-git-count-as-buildnum.sh
#  SubCalc
#
#  Created by Alexander Celeste on 2/13/19.
#  Copyright © 2019 Tenseg. All rights reserved.

#  Run this script after the 'Copy Bundle Resources' build phase
#  It will compute the git commit number and write that to the CFBundleVersion of the target's built Info.plist
#  From http://tgoode.com/2014/06/05/sensible-way-increment-bundle-version-cfbundleversion-xcode/#code

buildNumber=$(git rev-list --all --count)
appInfo="${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "$appInfo"
debugInfo="${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}.dSYM/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "$debugInfo"
