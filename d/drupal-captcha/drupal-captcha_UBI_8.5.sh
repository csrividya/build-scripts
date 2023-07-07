#!/bin/bash -e

# ----------------------------------------------------------------------------
# Package          : captcha
# Version          : 8.x-1.2
# Source repo      : https://git.drupalcode.org/project/captcha
# Tested on        : UBI 8.5
# Language         : PHP
# Travis-Check     : True
# Script License   : Apache License, Version 2 or later
# Maintainer       : Vikas Kumar <kumar.vikas@in.ibm.com>
#
# Disclaimer       : This script has been tested in root mode on given
# ==========         platform using the mentioned version of the package.
#                    It may not work as expected with newer versions of the
#                    package and/or distribution. In such case, please
#                    contact "Maintainer" of this script.
#
# ----------------------------------------------------------------------------

# Variables
PACKAGE_NAME=captcha
CORE_PACKAGE_NAME=drupal
PACKAGE_URL=https://git.drupalcode.org/project/captcha
CORE_PACKAGE_URL=https://github.com/drupal/drupal
#PACKAGE_VERSION is configurable can be passed as an argument.
PACKAGE_VERSION=${1:-8.x-1.2}


yum module enable php:7.4 -y
yum install -y git php php-json php-dom php-mbstring zip unzip gd gd-devel php-gd php-pdo php-mysqlnd
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && php composer-setup.php --install-dir=/bin --filename=composer

OS_NAME=`cat /etc/os-release | grep PRETTY_NAME | cut -d '=' -f2 | tr -d '"'`

#Check if package exists
if [ -d "$CORE_PACKAGE_NAME" ] ; then
  rm -rf $CORE_PACKAGE_NAME
  echo "$CORE_PACKAGE_NAME  | $PACKAGE_VERSION | $OS_NAME | GitHub | Removed existing package if any"

fi

if ! git clone $CORE_PACKAGE_URL $CORE_PACKAGE_NAME; then
  echo "------------------$PACKAGE_NAME:clone_fails---------------------------------------"
  echo "$CORE_PACKAGE_URL $CORE_PACKAGE_NAME"
  echo "$CORE_PACKAGE_NAME  |  $CORE_PACKAGE_URL |  $PACKAGE_VERSION | $OS_NAME | GitHub | Fail |  Clone_Fails"
  exit 1
fi

cd $CORE_PACKAGE_NAME
git checkout 8.9.0
composer update --no-interaction
composer config --no-plugins allow-plugins.composer/installers true
composer config --no-plugins allow-plugins.dealerdirect/phpcodesniffer-composer-installer true
composer config --no-plugins allow-plugins.drupal/core-project-message true
composer config --no-plugins allow-plugins.drupal/core-vendor-hardening true

if ! composer install --no-interaction; then
  echo "------------------$PACKAGE_NAME:install_fails-------------------------------------"
  echo "$PACKAGE_URL $PACKAGE_NAME"
  echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | $OS_NAME | GitHub | Fail |  Install_Fails"
  exit 1
fi

composer require --dev phpunit/phpunit --with-all-dependencies ^7 --no-interaction

cd modules/

#Check if package exists
if [ -d "$PACKAGE_NAME" ] ; then
  rm -rf $PACKAGE_NAME
  echo "$PACKAGE_NAME  | $PACKAGE_VERSION | $OS_NAME | GitHub | Removed existing package if any"

fi

if ! git clone $PACKAGE_URL $PACKAGE_NAME; then
  echo "------------------$PACKAGE_NAME:clone_fails---------------------------------------"
  echo "$PACKAGE_URL $PACKAGE_NAME"
  echo "$PACKAGE_NAME  |  $PACKAGE_URL |  $PACKAGE_VERSION | $OS_NAME | GitHub | Fail |  Clone_Fails"
  exit 1
fi

cd $PACKAGE_NAME
git checkout $PACKAGE_VERSION

cd ../../
cd core/

if ! ../vendor/phpunit/phpunit/phpunit ../modules/$PACKAGE_NAME/tests/src/Unit; then
  echo "------------------$PACKAGE_NAME:install_success_but_test_fails---------------------"
  echo "$PACKAGE_URL $PACKAGE_NAME"
  echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | $OS_NAME | GitHub | Fail |  Install_success_but_test_Fails"
  exit 1
else
  echo "------------------$PACKAGE_NAME:install_&_test_both_success-------------------------"
  echo "$PACKAGE_URL $PACKAGE_NAME"
  echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | $OS_NAME | GitHub  | Pass |  Both_Install_and_Test_Success"
  exit 0
fi
# drupal-captcha has Unit, Functional and Kernel test cases. Functional, Kernel tests need drupal framework to test. Unit tests can run without drupal framework setup.

# Follow https://github.com/ppc64le/build-scripts/blob/master/d/drupal-captcha/README.md link for drupal setup.

# To Run all test cases in one go:

# cd /opt/app-root/src/drupal/modules
# git clone  https://git.drupalcode.org/project/captcha
# cd captcha
# git checkout 8.x-1.2

# cd /opt/app-root/src/drupal/core/
# ../vendor/bin/drush pm:enable captcha

# ../vendor/phpunit/phpunit/phpunit ../modules/captcha/tests

# Output:
# -------
# PHPUnit 7.5.20 by Sebastian Bergmann and contributors.

# Testing ../modules/captcha/tests
# ..........................                                        26 / 26 (100%)

# Time: 10.61 minutes, Memory: 6.00 MB

# OK (26 tests, 467 assertions)
