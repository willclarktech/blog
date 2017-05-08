---
title: "Download a folder from a GitHub repo"
description: "Download a folder from a GitHub repository without cloning the whole thing."
category: tech
tags: [git, GitHub, version control]
---

Ever wanted to download part of a repo from GitHub without cloning the whole thing? You can do it with subversion:

```
svn export https://github.com/[username]/[respository]/trunk/[path/to/folder]
```

`trunk` here corresponds to the `master` branch, but you can replace `trunk` with `branches/[branchname]` if you want something on a different branch.

You can also verify the content of the folder you'll download first with `svn ls`:

```
svn ls https://github.com/[username]/[respository]/trunk/[path/to/folder]
```
