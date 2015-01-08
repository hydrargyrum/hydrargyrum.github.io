---
layout: mine
title: git tips
---

# Splitting a commit and copyedit it

When splitting a git commit in two parts, you may want to edit the first commit to fix some things.

Warning: this technique relies on [git-rebase(1)](https://www.kernel.org/pub/software/scm/git/docs/git-rebase.html) knowledge, don't try to use it if you don't know it before.

## Use case

For example, suppose you have done a commit (on HEAD) consisting of this in foo.c:

```
@@ -1 +1,5 @@
 /* stuff */
+
+int f() {
+       return 42;
+}
```

And you would like to have instead 2 commits, the first with (state S1):

```
@@ -1 +1,6 @@
 /* stuff */
+
+int f() {
+       /* TODO implement this function */
+       return -1;
+}
```

And the second with (state S2):

```
@@ -1,6 +1,5 @@
 /* stuff */
 
 int f() {
-       /* TODO implement this function */
-       return -1;
+       return 42;
 }
```

## How not to do it?

The simplest way would be to backup foo.c's real implementation (as it is in state S2), then edit foo.c to have the dummy implementation (state S1) and do a "`git commit --amend`" to fix the original commit, and after this restore the foo.c backup and finally create a second commit, but we want a somehow more satisfying solution.

Alternatively, you could unstage the "`return 42`" line thanks to "`git reset -p`", and then "`git commit --amend`" the first commit, so this line is not present, and create the second commit with the line "`return 42`".
But then you would not have the "`return -1`" in the first commit. You could do a "`git rebase -i HEAD~2`" to edit the first commit and insert the dummy implementation, but `git rebase` would encounter a conflict because the second patch did not expect a "`return -1`" to be present.

You could also have 2 commits, one that first applies S2, then the other which makes S1, and then directly swap the commits using "`git rebase -i HEAD~2`" but that would also cause conflicts. However, we're getting nearer to a better solution.

## How to do it without conflicts?

To do this, we will first need to edit foo.c, that we have currently in state S2, to get the state S1 (do "S2 -> S1"). Then commit it:

```
git add foo.c
git commit -m "S2 -> S1"
```

Here, the trick is to `git-revert` the last commit, to have the inverse transition, S1 -> S2:

```
git revert --no-edit HEAD
```

At this point, we have 3 commits, in chronological order:

  * S0->S2
  * S2->S1
  * S1->S2

And we want:

  * S0->S1
  * S1->S2

Now, we have smooth transitions, so `git-rebase` won't make any conflict. We can use "`git rebase -i HEAD~3`" to fuse the first 2 commits together, and possibly edit the commit messages to reflect our changes.

The rebase todo file should be edited to look like this:

```
pick ID1 Implement f
squash ID2 S2 -> S1
reword ID3 Revert "S2 -> S1"
```

## In a rebase

This technique can also be used to split a commit properly in the middle of another rebase. However, the rebase we do in this technique can't be applied while a rebase is in progress. You will only do the rebase after everything:

```
git-rebase -i origin/branch
# put some middle commit in "edit" state
# enters our technique
# edit the files
git-add the files
git-commit
git-revert HEAD
# finish the current rebase
git-rebase --continue # applies without conflict
# now we can finish our technique, doing another rebase
git-rebase -i origin/branch
```

## A helper script

```
#!/bin/sh
# encoding: utf-8

set -e
git commit --squash=HEAD
git revert --no-commit HEAD
git commit -m "should reword: adding `git log --oneline -1 HEAD~1`"
```

Setting `--squash` will create a commit message starting with the string "squash!", [and a commit message starting with "squash!" will make the rebase-todo file contain a squash instead of the default pickup action](https://coderwall.com/p/hh-4ea/git-rebase-autosquash), when you use "`git rebase -i --autosquash HEAD~3`".
