---
layout: mine
title: git-rebase tips
tags: git rebase git-rebase
---

# `git-rebase` reminder

[`git-rebase`](https://git-scm.com/book/en/v2/Git-Branching-Rebasing) is a command to make a branch's commits start at another point, typically to start with a fresher base, for example if the `master` branch has moved since a `feature` branch was started off `master`.

[`git-rebase -i`](https://git-scm.com/docs/git-rebase) (interactive rebasing) can do the same, but it also starts an editor on an instructions file. This file describes what instructions should be made on the commits of the branch, for example [what commits to keep, if they should be ordered differently, and more](https://git-scm.com/book/en/v2/Git-Tools-Rewriting-History). `git-rebase -i` will process the edited instructions file as soon as the editor is closed. This instructions file is called a `todo` in git parlance.

It's good to know interactive rebasing before reading the rest of this article.

# Executing a command after each commit

`git rebase -i -x "make"` inserts `exec make` lines after each commit pick in the `todo` file. If the command fails, the rebase will be paused.
This is a simple way to ensure the code from every commit builds properly, and let one edit the code at a specific commit if it failed to build.

After the build and files are fixed, `git-add` and `git commit --amend` can be used to fix the commit's content. Then, `git-rebase --continue` will resume the rebasing/build-checking.

# Using interactive rebase without interaction

Sometimes, you'd like to use the `todo` programmatically. You don't want to pop an editor but instead you'd like to use your `todo` file.

`git-rebase` can be told not to pop an editor but use a custom command instead. This is controled with the `GIT_SEQUENCE_EDITOR` environment variable, or the [`sequence.editor`](https://git-scm.com/docs/git-config#git-config-sequenceeditor) `git-config` option.

`git rebase -c "sequence.editor=some command --args" -i` will start an interactive rebase but will not pop an editor on the `todo` file. Instead, it will run `some command --args <path to the todo file>`.
The provided command should edit the given `todo` file in-place and exit. Then, `git-rebase` will process instructions from the `todo` file as usual.

## Drop a commit

Suppose you want to drop commit `123456` from the `feature` branch. You'd need to do an interactive rebase, and remove the line referencing `123456` (or replace `pick` with `drop` if using [`rebase.abbreviateCommands`](https://git-scm.com/docs/git-config#git-config-rebasemissingCommitsCheck) option) in the `todo` file.

It's possible to script editing the `todo` file:

	git rebase -c "sequence.editor=sed -i /123456/d" -i

* `sed -i` will process and edit the todo file in-place
* `/123456/` will look for a line matching `123456`
* and [`d`](http://pubs.opengroup.org/onlinepubs/9699919799/utilities/sed.html) will delete that line
* the rest of the todo file is untouched

## Regularly exporting parts of a branch to a dedicated branch (or the reverse)

Sometimes, in a `git` repository, you build multiple unrelated features on your `develop` branch to test them on a permanent basis.

	o [develop] feature 2: b
	| feature 2: a
	| feature 1: b
	| feature 1: a
	| {prod/master} 0.8 release

You don't want to use `git-checkout(1)` everytime because you'd have to choose. Also, the path of the project is a single directory, so it's not possible to use from any [`git-worktree(1)`](https://git-scm.com/docs/git-worktree).

Howevery, you would like to push each feature on your repository on separate branches.

So, you would checkout to the branch when willing to push (or use `git-worktree`), `git-cherry-pick` commits associated to one feature from `develop`, and finally `git-push`.


	% git checkout -b feature1 prod/master
	% git cherry-pick ...
	% tig
	o [feature1] feature1: b
	| feature1: a
	| {prod/master} 0.8 release

But this is cumbersome to do multiple times. When amending commits on branch `develop`, commits from branch `feature1` become obsolete.

### git-recpbranch

[Using a basic script](https://github.com/hydrargyrum/attic/blob/master/git/git-recpbranch), we could take updated commits from `develop` and drop the obsolete ones.

Since there's no semantic id on git, it's impossible to identify which commit is an old "version", not amended, of another commit.

If we can base ourselves on the commit title line, it'll be easy to match commits. Then we can replace `pick old_sha1` with `pick new_sha1`.

# `autoStash` and `autoSquash`

[`git config rebase.autoStash true`](https://git-scm.com/docs/git-rebase#git-rebase---autostash) will automatically stash when a `git-rebase` is done and there are uncommitted changes, and will pop stash after the rebase is finished. Handy when you rebase frequently in the middle of a task.

[`git config rebase.autoSquash true`](https://git-scm.com/docs/git-rebase#git-rebase---autosquash) will automatically move some commits made with [`--fixup`](https://robots.thoughtbot.com/autosquashing-git-commits) near the commit they're supposed to fixup.

Combined with some [`tig` keyboard shortcuts](./2017-08-10-tig.html), it can be quicken dispatching a few changes to amend some commits.

# More configuration bits

If you use rebase often and also create branches often, `git config branch.autoSetupRebase always` will configure any new branch to perform a rebase when using `git-pull`, instead of performing a merge.
