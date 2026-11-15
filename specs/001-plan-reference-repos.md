I like the direction, however I want the cloning and perhaps later updating of the important repos captured in a justfile at /Users/jeff/jwm/proj/emacs-config/justfile.

So make the plan be:

1. implement choice 3: both for /Users/jeff/jwm/proj/emacs-config/reference-configs.md

2. build justfile recipes to:
   2.1. add a new repo that we want to keep a reference to
       2.1.1. ie, clone a repo by name
       2.1.2. store state in the justfile of all of the reference repos we are tracking
           2.1.2.1. so add this new repo to that stored state in the justfile
       2.1.3. this is the create step in CRUD
   2.2. ensure all of the repos in our reference list are synced and up to date on this file system
       2.2.1. this might be a clone, or it might be just a git pull
