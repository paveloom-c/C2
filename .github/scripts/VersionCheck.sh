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

# Checking if there is the feature branch
if git branch -a | grep -qw $FEATURE_BRANCH_NAME; then

     printf "Found the feature branch.\n\n"

     # Checking if the last commit on master has a tag
     if echo "$MASTER_TAG" | grep -q -v "-"; then

          printf "Found a tag at the last commit on master.\n\n"

          printf "Master tag:\n"
          echo $MASTER_TAG

          # Checking out to the feature branch
          git checkout -q $FEATURE_BRANCH_NAME

          # Checking if the last commit on master is a parent to the feature branch
          if git describe --tags $FEATURE_BRANCH_NAME | grep -q $MASTER_TAG; then

               printf "\nThe last commit on master is a parent to the feature branch.\n\n"

               # Getting the current release tag
               CURRENT_TAG="$(grep -o "\-.*\-" README.md | sed 's/-//g')"

               printf "Current tag from README.md:\n"
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

          else

               printf "\nThe last commit on master is NOT a parent to the feature branch.\n\n"

               # Checking out to the feature branch
               git checkout -q master

               printf "Checking if the current tag is the same as the master tag.\n\n"

               # Getting the current release tag
               CURRENT_TAG="$(grep -o "\-.*\-" README.md | sed 's/-//g')"

               printf "Current tag from README.md:\n"
               echo $CURRENT_TAG

               # Checking if the current tag is the same as the master tag
               if [ ! $CURRENT_TAG == $MASTER_TAG ]; then

                    printf "\nThe current tag and the master tag are NOT equal."
                    printf "\nThe master tag should be changed to the current tag.\n\n"

                    exit 1

               fi

               printf "\nEverything is okay.\n"

          fi

     else

          printf "There is no tag at the last commit on master.\n\n"

          printf "Doing nothing.\n"

     fi

else

     printf "There is no feature branch like the specified one.\n\n"

     # Checking if the last commit on master has a tag
     if echo "$MASTER_TAG" | grep -q -v "-"; then

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

     else

          printf "There is no tag at the last commit on master.\n\n"

          printf "Doing nothing.\n"       

     fi

fi