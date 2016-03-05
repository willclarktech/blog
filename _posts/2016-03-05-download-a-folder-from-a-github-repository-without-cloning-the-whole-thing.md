---
layout: post
title: "Download a folder from a GitHub repository without cloning the whole thing"
description: "Quick command line tool for downloading a specific folder from a GitHub repository without cloning the whole thing."
category: tools
tags: [git, GitHub, version control]
---
{% include JB/setup %}

I have two repositories, where one is a rewrite of the other using updated technologies. Sometimes I want to copy across a file or folder from one repository to another because the new version will just be the same as the old version (e.g. a font folder). I discovered this great command for doing just that using subversion:

```
svn export https://github.com/[username]/[respository]/trunk/[path/to/folder]
```

`trunk` here corresponds to the `master` branch, but you can replace `trunk` with `branches/[branchname]` if you want something on a different branch.

You can also verify the content of the folder you'll download first with `svn ls`:

```
svn ls https://github.com/[username]/[respository]/trunk/[path/to/folder]
```
