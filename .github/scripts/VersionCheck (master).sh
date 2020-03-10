#!/bin/bash

# Printing the script header
printf "\nRunning a script which is checking whether the current version of\n"
printf "the release is different from the previous version of the release.\n\n"

# Specifying a name of a feature branch
FEATURE_BRANCH_NAME="feature"

# Specifying a name of a temporary folder
TMP_FOLDER_NAME="tmp"

# Specifying the inital number of errors
ERROR_COUNT=0

# Specifying version checking functions

function version_check_ipynb {

     printf "\nRunning a version checking function for the following file:\n"
     echo "$1"

     if grep -q "Release version: \[$CURRENT_TAG]" $1 && grep -q "releases/tag/v$CURRENT_TAG" $1; then

          printf "\nThe version in this file is matching to the current one.\n"

     else

          printf "\nThe version in this file is NOT matching to the current one.\n"
          ERROR_COUNT=$((ERROR_COUNT+1))

     fi

}

function version_check_zip_ipynb {

     printf "\nRunning a version checking function for the following file:\n"
     echo "$2,"
     printf "which is located in the following .zip archive:\n"
     echo "$1"

     # Creating a tmp directory if not created
     if [ ! -d $TMP_FOLDER_NAME ]; then
          mkdir $TMP_FOLDER_NAME

     # Deleting all files from the temporary directory
     else
          rm -rf tmp/*
     fi

     printf "\nUnpacking the file to the temporary directory...\n"

     # Unpacking the zip file
     unzip -q "$1" -d $TMP_FOLDER_NAME

     if grep -q "Release version: \[$CURRENT_TAG]" tmp/$2 && grep -q "releases/tag/v$CURRENT_TAG" tmp/$2; then

          printf "\nThe version in this file is matching to the current one.\n"

     else

          printf "\nThe version in this file is NOT matching to the current one.\n"
          ERROR_COUNT=$((ERROR_COUNT+1))

     fi

}

function run_version_checks {

     version_check_ipynb "Notebooks/Base/celerite/Revised/celerite.ipynb"
     version_check_ipynb "Notebooks/Base/george/george.ipynb"

     version_check_zip_ipynb "Archives/Notebooks.zip" "Notebooks/Base/celerite/Revised/celerite.ipynb"
     version_check_zip_ipynb "Archives/Notebooks/Base.zip" "Base/celerite/Revised/celerite.ipynb"
     version_check_zip_ipynb "Archives/Notebooks/Base.zip" "Base/george/george.ipynb"

}

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