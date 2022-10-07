#!/bin/bash

cd .
date
PR_VERSION=$(mvn org.apache.maven.plugins:maven-help-plugin:evaluate -Dexpression=project.version | sed -n -e '/^\[.*\]/ !{ /^[0-9]/ { p; q } }')

echo
echo "- Master version:       $MASTER_VERSION"
echo "- pull request version: $PR_VERSION"
echo

FAIL=0

if [ "$MASTER_VERSION" = "$PR_VERSION" ]
then
	echo "::error::ERROR - The pom.xml file of the pull request have the same version of the master branch"
else
	if [  "$MASTER_VERSION" = "`echo -e "$MASTER_VERSION\n$PR_VERSION" | sort -V | head -n1`" ]
	then
         	echo "OK - the version of the pullrequest is greater than the version in the main branch"
        else
        	echo "::error::ERROR - The version in the pom.xml of the pull request is less of the version of the master branch"
        	FAIL=1
        fi
fi

echo

DISCORDING_VERSION=$(grep -rnw . -e '* @version' | grep -v "@version $PR_VERSION")

echo "@version $PR_VERSION"

if [ -z "${DISCORDING_VERSION-unset}" ]
then
	echo "OK - The version in the javado is valid"
else
	echo "::error::ERROR - the sequent file have a invalid versione reported:"
	ERROR_FILES=$(grep -rnw . -e '* @version' | grep -v "@version $PR_VERSION" )
	echo "::error::$ERROR_FILES"
        FAIL=1
fi

exit $FAIL
