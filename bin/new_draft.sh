#!/bin/sh
if [ -z $1 ];
then echo "No slug specified";
else echo '---
title: "Title"
description: "This will be tweeted"
category: tech|future|philosophy
tags: []
---' > "_drafts/$1.md";
fi
