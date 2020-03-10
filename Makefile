
     ## This is a Makefile template for code publication on GitHub.

     ## Repository on GitHub: https://github.com/Paveloom/B1
     ## Documentation: https://www.notion.so/paveloom/B1-fefcaf42ddf541d4b11cfcab63c2f018

     ## Release version: 2.1.2
     ## Documentation version: 2.1.0

     ## Author: Pavel Sobolev (http://paveloom.tk)

     ## Make sure that your text editor visually displays a tabulation
     ## symbol equally to the visual representation of five spaces.

     # Makefile settings

     ## Name of your build tool
     make_name := make

     ## Specifying the shell
     SHELL := /bin/bash

     ## Telling makefile to execute all rules using one instance of the shell
     .ONESHELL :

     ## Special target to make Makefile silent
     ## (without rules specifications suppresses output from all rules)

     .SILENT :

     ## Phony targets
     .PHONY : git, git-am, archive

     ## Default rule when calling `make`
     ALL : git



     # Block of the rules for code publication on GitHub

     ## Username on GitHub
     username := Paveloom

     ## Feature branch name
     FEATURE_BRANCH := feature

     ## Rule for creation and publishing of a commit

     git :
 
	      # Determining current branch
	      CURRENT_BRANCH=$$(git status | head -n 1 | cut -d " " -f 3)

	      # Checking the current branch 
	      if [ "$$CURRENT_BRANCH" = "${FEATURE_BRANCH}" ]; then

	           # Determining the last tag
	           LAST_TAG=$$(git describe --tag)

	           # Determining if last commit has a tag
	           if echo $$LAST_TAG | grep -qv "-"; then

	                # Checking if the last commit is a generated one
	                if echo $$LAST_TAG | grep -q "_"; then

	                     # Determining the number of the last commit
	                     CURRENT_NUMBER=$$(echo $$LAST_TAG | grep -o "_[0-9]\+" | sed 's/_//')

	                     # Iterating the current number
	                     NEXT_NUMBER=$$(( $$CURRENT_NUMBER + 1 ))

	                     # Creating a new tag
	                     NEXT_TAG=$$(echo $$LAST_TAG | sed "s/_$$CURRENT_NUMBER/_$$NEXT_NUMBER/")

	                     # Creating a commit
	                     git add -A
	                     git commit -e
                     
	                     # Checking if a commit was created
	                     if [ $$? -eq 0 ]; then

	                          # Tagging the new tag
	                          git tag -a $$NEXT_TAG -m "$$NEXT_TAG"

	                          # Deleting the previous tag locally and remotely
	                          git tag -d $$LAST_TAG
	                          git push origin :$$LAST_TAG

	                          # Pushing
	                          git push --follow-tags

	                     fi

	                else

	                     # Creating a new tag
	                     NEXT_TAG=$$(echo "$$LAST_TAG _${FEATURE_BRANCH}_1" | sed "s/\ //")

	                     # Creating a commit
	                     git add -A
	                     git commit -e

	                     # Checking if a commit was created
	                     if [ $$? -eq 0 ]; then

	                          # Tagging the new tag
	                          git tag -a $$NEXT_TAG -m "$$NEXT_TAG"

	                          # Pushing
	                          git push --follow-tags

	                     fi

	                fi

	           else

	                # Creating a commit
	                git add -A
	                git commit -e

	                # Checking if a commit was created
	                if [ $$? -eq 0 ]; then

	                     # Pushing
	                     git push

	                fi
  
	           fi

	      else

	           # Creating a commit
	           git add -A
	           git commit -e

	           # Checking if a commit was created
	           if [ $$? -eq 0 ]; then

	                # Pushing
	                git push

	           fi

	      fi

     # Rule for deleting the last generated tag
     # on the feature branch locally and remotely

     final : 

	        # Determining current branch
	        CURRENT_BRANCH=$$(git status | head -n 1 | cut -d " " -f 3)

	        # Checking the current branch
	        if [ "$$CURRENT_BRANCH" = "${FEATURE_BRANCH}" ]; then

	             # Determining the last tag
	             LAST_TAG=$$(git describe --tag)

	             # Deleting the lat tag remotely
	             git push origin :$$LAST_TAG

	             # Deleting the last tag locally
	             git tag -d $$LAST_TAG

	        fi

     ## Rule for amending of the last commit

     git-am :
	         git add -A
	         git commit --amend
	         git push --force-with-lease

     # Rule for creating of archives

     archive :
	          cd Notebooks/ && find Base/ -path '*/.*' -prune -o -type f -print | zip ../Archives/Notebooks/Base.zip -FS -q -@
	          # cd Notebooks/ && find Comparison/ -path '*/.*' -prune -o -type f -print | zip ../Archives/Notebooks/Comparison.zip -FS -q -@
	          cd Notebooks/ && find Tests/ -path '*/.*' -prune -o -type f -print | zip ../Archives/Notebooks/Tests.zip -FS -q -@
	          find Notebooks/ -path '*/.*' -prune -o -type f -print | zip Archives/Notebooks.zip -FS -q -@
