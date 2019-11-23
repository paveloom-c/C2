
     ## A detailed description of the template for this makefile can be found
     ## on the repository's Wiki at https://github.com/Paveloom/B1 (Russian)

     ## For the correct display of the contents, it is recommended
     ## to use gedit or Visual Studio Code.

     # Makefile settings

	## A coordinator's name 
     make_name := make

     ## A special target to make Makefile silent
     ## (without rules being specified suppresses output from all rules)
     
     .SILENT : 

     ## Phony targets

     .PHONY : git, git-am, git-dev, git-dev-ready, git-new, git-new-2, \
		    git-dev-re, git-dev-ready-re, force_change, git-clean



     # A block of the rules for development and publication of code to GitHub
     
     ## A username on GitHub
     username := Paveloom
     
     ## Force changes? (see the usage scenarios for rules 'git-dev'
     ## and 'git-dev-ready'; see what happens if .true. appears in the 'force-change' rule)
     force-changes := true
		
	## A rule for creation and publishing of a commit

     git : 
		 git add -A
		 git commit -e
		 git push
		 
     ## A rule for amending the last commit
		 
     git-am : 
	         git add -A
	         git commit --amend
	         git push --force-with-lease
	         
	## A rule for updating the 'master' branch to the current state of the 'dev' branch
	## (merge without a merge commit; the method creates the supportive branch named 'feature')
			
     git-dev : 
	          if [ "true" = "$(force-changes)" ]; then \
	               git checkout dev; \
	               $(make_name) force-change; \
	               git add -A; \
	               git commit --amend --no-edit; \
	               git push --force-with-lease; \
	          fi
     
			git checkout master
			git checkout -b feature
			git merge --squash dev -Xtheirs
			git commit
			git checkout master
			git merge feature
			git branch -D feature
			git push --force-with-lease
			git checkout dev
			
	## A rule for updating the 'dev' branch to the current state of the 'master' branch
	## (an analogue to the 'git-dev' rule, but in the opposite way; reasonable to use only if
	## changes were made on the 'master' branch after the last merge)
	
     git-dev-ready : 
	                if [ "true" = "$(force-changes)" ]; then \
	                     git checkout master; \
	                     $(make_name) force-change; \
	                     git add -A; \
	                     git commit --amend --no-edit; \
	                     git push --force-with-lease; \
	                fi

	                git checkout dev
	                git checkout -b dev-upd
	                git merge --squash master -Xtheirs
	                git commit
	                git checkout dev
	                git merge dev-upd
	                git branch -D dev-upd
	                git push --force-with-lease

     ## A rule to connect a dedicated repository, creating one branch
     ## and pushing this Makefile as an initial commit

     ifeq (git-new, $(firstword $(MAKECMDGOALS)))
          new_rep := $(wordlist 2, 2, $(MAKECMDGOALS))
          $(eval $(new_rep):;@#)
     endif

     git-new : 
			$(make_name) git-clean
			git init
			git remote add origin git@github.com:$(username)/$(new_rep).git
			git add Makefile
			git commit -m "Initial commit"
			git push -u origin master
			
     ## A rule to connect a dedicated repository, creating two branches
     ## ('master' and 'dev') and pushing this Makefile as an initial commit

     ifeq (git-new-2, $(firstword $(MAKECMDGOALS)))
          new_rep := $(wordlist 2, 2, $(MAKECMDGOALS))
          $(eval $(new_rep):;@#)
     endif

     git-new-2 : 
			  $(make_name) git-clean
			  git init
			  git remote add origin git@github.com:$(username)/$(new_rep).git
			  git add Makefile
			  git commit -m "Initial commit"
			  git push -u origin master
			  git checkout -b dev
			  git push -u origin dev
			
	## A rule to repeat the last transfer of changes made in the 'dev' branch to the 'master' branch
	## ('reset --hard' is used, so it's reasonable to use only if you know what you're doing)
	
     git-dev-re :
			   echo
			   echo "'reset --hard' will be used. Make sure that the last commit on the 'master' branch was created by pushing changes from the 'dev' branch."
			   echo "Copy, if necessary, the commit message from the last commit on the 'master' branch:"
			   echo
			   
			   git log master -1 --pretty=format:%s; echo
			   git log master -1 --pretty=format:%b; echo
			   
			   while [ -z "$$CONTINUE" ]; do \
	                  read -r -p "Continue? [y]: " CONTINUE; \
	             done ; \
	             [ $$CONTINUE = "y" ] || [ $$CONTINUE = "Y" ] || (echo; echo "Canceled."; echo; exit 1;)
	             
	             echo
			   git checkout master
			   git reset --hard HEAD~1
			   $(make_name) git-dev
			   
	## A rule to repeat the last transfer of changes made in the 'master' branch to the 'dev' branch
	## ('reset --hard' is used, so it's reasonable to use only if you know what you're doing)
	
     git-dev-ready-re :
			         echo
			         echo "'reset --hard' will be used. Make sure that the last commit on the 'dev' branch was created by pushing changes from the 'master' branch."
			         echo "Copy, if necessary, the commit message from the last commit on the 'dev' branch:"
			         echo
			         
			         git log dev -1 --pretty=format:%s; echo
			         git log dev -1 --pretty=format:%b; echo
			         
			         while [ -z "$$CONTINUE" ]; do \
	                        read -r -p "Continue? [y]: " CONTINUE; \
	                   done ; \
	                   [ $$CONTINUE = "y" ] || [ $$CONTINUE = "Y" ] || (echo; echo "Canceled."; echo; exit 1;)
	             
	                   echo
			         git checkout dev
			         git reset --hard HEAD~1
			         $(make_name) git-dev-ready
	
     ## A rule to force changes (adds / deletes spaces in the last row of this file;
     ## creates a blank line if necessary; usage is controlled by the 'force-changes' variable)
     
     force-change : 
	               if tail Makefile -n 1 | grep '[[:alpha:]]'; then \
	                    echo "$f" >> Makefile; \
	               else \
	                    if tail Makefile -n 1 | grep ' [[:space:]]'; then \
	                         truncate -s-1 Makefile; \
	                    else \
	                         truncate -s-1 Makefile; \
	                         echo "$f " >> Makefile; \
	                    fi \
	               fi
	
     ## A rule to delete a Git repository
     
     git-clean : 
		       rm -rf .git
 