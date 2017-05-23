---
title: "Multiple argument shortcut in bash"
description: "Bash brace expansions can reduce typing similar arguments out twice"
category: tech
tags: [bash, cli]
---

Until recently I was using brace expansions in bash assuming that they were some semi-intelligent way of specifying multiple files and directories. For example:

```bash
rm ./{TODO.md,testing.js,blah.sh~}
```

But they're actually just a concise way of specifying lists of strings, so I've started using them a lot more often for things like the following, where previously I would have been typing out two very similar arguments:

```bash
mv ./misspe{z,l}t.txt
cp ./logs{,-2017-05-01}.txt
mv some_dir/{subdir/,}should_be_in_somedir.txt
```
