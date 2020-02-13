
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

     ## Rule for creation and publishing of a commit

     git :
	      git add -A
	      git commit -e
	      git push

     ## Rule for amending of the last commit

     git-am :
	         git add -A
	         git commit --amend
	         git push --force-with-lease

     # Rule for creating of archives

     archive :
	          cd tests/period_plots/ && find . -path '*/.*' -prune -o -type f -print | zip ../../archives/tests/period_plots.zip -FS -q -@
	          cd tests/sigma_clipping/ && find . -path '*/.*' -prune -o -type f -print | zip ../../archives/tests/sigma_clipping.zip -FS -q -@
