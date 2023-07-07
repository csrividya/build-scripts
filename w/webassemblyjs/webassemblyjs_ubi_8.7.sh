#!/bin/bash -e
# ----------------------------------------------------------------------------
#
# Package	    : webassemblyjs
# Version	    : v1.11.3
# Source repo	    : https://github.com/xtuc/webassemblyjs.git
# Tested on	    : ubi 8.7
# Language          : JavaScript
# Travis-Check      : true
# Script License    : Apache License, Version 2 or later
# Maintainer	    : Pratik Tonage <Pratik.Tonage@ibm.com>
#
# Disclaimer: This script has been tested in root mode on given
# ==========  platform using the mentioned version of the package.
#             It may not work as expected with newer versions of the
#             package and/or distribution. In such case, please
#             contact "Maintainer" of this script.
#
# ----------------------------------------------------------------------------

# Variables
PACKAGE_NAME="webassemblyjs"
PACKAGE_VERSION=${1:-"v1.11.3"}
PACKAGE_URL=https://github.com/xtuc/webassemblyjs.git
HOME_DIR=${PWD}

# Install dependencies
#yum -y update
yum install -y yum-utils wget git gcc gcc-c++ make openssl-devel

#Installing nvm
cd $HOME_DIR
wget https://nodejs.org/dist/v14.21.2/node-v14.21.2-linux-ppc64le.tar.gz
tar -xzf node-v14.21.2-linux-ppc64le.tar.gz
export PATH=$HOME_DIR/node-v14.21.2-linux-ppc64le/bin:$PATH
node -v

# clone the repository
cd $HOME_DIR
git clone $PACKAGE_URL
cd $PACKAGE_NAME
git checkout $PACKAGE_VERSION

# Install yarn
npm install yarn -g

# Build 
if ! yarn install; then
    echo "------------------$PACKAGE_NAME:Build_fails-------------------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Build_Fails"
    exit 1
fi

# Test 
if ! yarn test; then
    echo "------------------$PACKAGE_NAME:build_success_but_test_fails---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  build_success_but_test_Fails"
    exit 2
else
    echo "------------------$PACKAGE_NAME:build_&_test_both_success-------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub  | Pass |  both_build_and_test_success"
    exit 0
fi

#There are some issues for version V1.11.4 and a PR is open at https://github.com/xtuc/webassemblyjs/pull/1135
#to upgrade dependencies in the ast package to version 1.11.4
#This is working on master and for v1.11.3.
