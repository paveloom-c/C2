#!/bin/bash

# Printing the script header
printf "\nRunning a script which is checking whether the current version of\n"
printf "the release is different from the previous version of the release.\n\n"

# Specifying a name of a feature branch
FEATURE_BRANCH_NAME="feature"

# Specifying the inital number of errors
ERROR_COUNT=0

# Specifying version checking functions

function version_check_pdf {

     printf "\nRunning a version checking function for the following file:\n"
     echo "$1"

     # Converting PDF to plain text
     pdftotext "$1"

     # Defining the path of the text file
     TEXT_FILE_PATH=$(echo ${1::-3}txt)

     # Checking if the version specified is correct
     if grep -q "Release version: $CURRENT_TAG" "$TEXT_FILE_PATH"; then

          printf "\nThe version in this file is matching to the current one.\n"

     else

          printf "\nThe version in this file is NOT matching to the current one.\n"
          ERROR_COUNT=$((ERROR_COUNT+1))

     fi

}

function run_version_checks {

     version_check_pdf "Comparison/Comparison Chart.pdf"

}

# Checking out to master
git checkout -q master

# Saving an output of the next command in a variable
MASTER_TAG="$(git describe --tags master)"

printf "Master tag:\n"
echo $MASTER_TAG

# Checking out to the feature branch
git checkout -q $FEATURE_BRANCH_NAME

# Getting the current release tag
CURRENT_TAG="$(grep -o "release\-v.*\-informational" README.md | grep -o "\-.*\-" | sed 's/-//g')"

printf "\nCurrent tag from README.md:\n"
echo $CURRENT_TAG

# Checking if the current tag is changed
if [ $CURRENT_TAG == $MASTER_TAG ]; then

     printf "\nThe current tag and the master tag are equal."
     printf "\nAdjust the current tag according to Semantic Versioning.\n\n"

     exit 1

fi

# Escaping dots in CURRENT_TAG variable
CURRENT_TAG="$(echo $CURRENT_TAG | sed 's/v//' | sed 's/\./\\./g')"

# Checking if another tag in README.md is the same
if ! grep -q "releases/tag/v$CURRENT_TAG" README.md; then

     printf "\nThe specified tags are different in README.md.\n\n"

     exit 1

fi

# Running version checks for files and archives
run_version_checks

if [ "$ERROR_COUNT" -gt 0 ]; then

     printf "\nNumber of errors: $ERROR_COUNT\n\n"
     exit 1

else

     printf "\nEverything is okay.\n"

fi