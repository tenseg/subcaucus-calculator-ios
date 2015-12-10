#!/bin/bash
 
#  retrieve-buildnum-commit.sh
#  Usage: In project folder run `retrieve-buildnum-commit.sh n [branch]`
# From http://tgoode.com/2014/06/05/sensible-way-increment-bundle-version-cfbundleversion-xcode/#code
 
branch=${2:-'master'}
SHA1=$(git rev-list $branch | tail -n $1 | head -n 1)
echo $SHA1