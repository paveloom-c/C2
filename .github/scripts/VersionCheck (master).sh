#!/bin/bash

# Printing the script header
printf "\nRunning a script which is checking whether the current version of\n"
printf "the release is different from the previous version of the release.\n\n"

# Specifying a name of a feature branch
FEATURE_BRANCH_NAME="feature"

# Checking out to master
git checkout -q master

# Saving an output of the next command in a variable
MASTER_TAG="$(git describe --tags master)"

printf "Checking if the current tag is the same as the master tag.\n\n"

# Getting the current release tag
CURRENT_TAG="$(grep -o "\-.*\-" README.md | sed 's/-//g')"

printf "Master tag:\n"
echo $MASTER_TAG

printf "\nCurrent tag from README.md:\n"
echo $CURRENT_TAG

# Checking if the current tag is the same as the master tag
if [ ! $CURRENT_TAG == $MASTER_TAG ]; then

     printf "\nThe current tag and the master tag are NOT equal."
     printf "\nThe master tag should be changed to the current tag.\n\n"

     exit 1

fi

printf "\nEverything is okay.\n"