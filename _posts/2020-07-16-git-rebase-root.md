---
title: "git rebase --root"
description: "Edit initial commits with git rebase"
category: tech
tags: [git]
---

It happens. You’ve just created a new repository, you’re a few commits in, and then you realise you messed up the initial commit. Maybe you used another repository as a template and forgot to replace the repository name somewhere.

No big deal: you can just make the change and add a commit on top, right? Sure, but it’s so close to the start maybe the perfectionist in you is tempted to delete the repository and start again. Or maybe this project is supposed to show off your skills to a prospective employer and you really need everything to be _perfect_. Or maybe you accidentally included a huge binary file in that initial commit and now it’s going to pollute your git history forever unless you start from scratch.

I’m a big fan of `git rebase --interactive` for cleaning up messy histories, but usually you tell git what the starting point is, which means you normally can’t edit the initial commit because there’s no commit further back to start from. I just learned about the `--root` option though, which lets you do just that. Perfectionists of the world, rejoice!
