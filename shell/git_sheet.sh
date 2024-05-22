Setting up SSH keys with Git:
1) Generate key
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
2) Adding your SSH key to the ssh-agent
eval "$(ssh-agent -s)"
vi ~/.ssh/config
Host *
 AddKeysToAgent yes
 UseKeychain yes
 IdentityFile ~/.ssh/id_rsa
 ssh-add -K ~/.ssh/id_rsa
 3) Add SSH keys to GitHub
 pbcopy < ~/.ssh/id_rsa.pub  and paste in GitHub 

Configuring specific keys to use with Git
vi ~/.ssh/config
Host github.com
IdentityFile ~/.ssh/id_rsa

git config --global user.name "Sanju"
git config --global user.email "sanjeev.it@gmail.com"

cat ~/.gitconfig
[user]
	name = Sanju
	email = sanjeev.it@gmail.com

git config --global --list
user.name=Sanju
user.email=sanjeev.it@gmail.com

Add a local project to GitHub:
1) Create a new repository on GitHub. 
To avoid errors, do not initialize the new repository with README, license, or gitignore files. 
You can add these files after your project has been pushed to GitHub.

2) Open Terminal.Change the current working directory to your local project.
  Initialize the local directory as a Git repository.
  git init
  git add .
  git commit -m "message"
3) Push code to GitHub repo: 
git remote set-url origin <Uyour repo URL>
for example: 
git remote add origin git@github.com:enterthematrix/hms.git
git push -u origin master


**Eclipse:**

Ctrl+Shift+T - Type Search
CMD + T ==> Type hierarchy of the class
CMD + O ==> Outline of the class
F3 ==> Method defination
Ctrl + Shift + G ==> To see all the methods who are invoking a given method
Ctrl+Alt+H ==> Method Call hierarchy
Ctrl + H ==> Text/File search

Code CleanUp / Generation

Ctrl + Shift + O ==> Organize/Clean import statements
Ctrl + Shift + F ==> Code formatting/indentation 
Ctrl + / ==> Comment
Ctrl + shift+  / ==> Block Comment

Template for new object:

Type 'new' and hit ==> Ctrl + Space

Template for a foreach loop:
Type 'foreach' and hit ==> Ctrl + Space
switch and hit ==> Ctrl + Space
for and hit ==> Ctrl + Space
main and hit ==> Ctrl + Space
public and hit ==> Ctrl + Space

Refactoring:
select code and go to source code generate options 

Debugger:

Breakpoint: The point where the execution will pause
Step Over: Execute the current line
Step Into: Step into a method call
Step return: To get out of 'Step Into'


=============================================================== Development Notes =================================================================
#Starting with a new repo:

## Create  a new repo on GitHub
1. git init  # go to your local and initialize the local git repo
2. git add .   # add your code to local git
3. git commit -m "initial commit"  # commit your changes to local git
4. git remote add origin git@github.com:enterthematrix/docker-react.git # connect your local repo to GitHub repository
5. git push origin master  # push your changes to GitHub repository

## Commiting fix to SDC

 # Create a new branch with the Jira id

 git checkout -b SDC-11465 origin/master
 git status
 #Make changes and commit

 git add <files>
 git commit

 # Verify the changes can be seen in the got log
 git log

 # Fetach changes by others and rebase

 git fetch
 git rebase -i
 #Send for review:

 git review -R

## Backtracking changes:

git stash - put away changes
git fetch origin - get recent chganges
git rebase origin/master - rebase

## Retrive stashed changes:
git stash pop


## Enable remote debugger:
export SDC_JAVA_OPTS=-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=51598

## Reverting to older git commit:
git reflog
git reset --hard  HEAD@{8}

reverting specific changes from commit:
https://stackoverflow.com/questions/12481639/remove-files-from-git-commit

git reset --soft HEAD~1
#Back out changes like below:
git reset HEAD ./out/*
git reset HEAD ./MiscJavaClients/target/*
git reset HEAD ./.idea/*
git reset HEAD ./MiscJavaClients/target/*
git status
#commit rest of the changes.
git commit -c ORIG_HEAD
#For example:
git commit -c HEAD@{8}