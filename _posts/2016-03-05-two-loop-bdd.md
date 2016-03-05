---
layout: post
title: "Two loop BDD"
description: "The two-loop BDD process designed by Konstantin Kudryashov to incorporate DDD ideas. Modelling by example."
category: process
tags: [best practices,web development,bdd,ddd,tdd,unit testing,acceptance testing,end-to-end testing]
---
{% include JB/setup %}

Here is the two-loop BDD process making use of "modelling by example" designed by Konstantin Kudryashov to incorporate DDD ideas. I've extracted it from these resources: [Video](https://vimeo.com/149564297), [Blog post](http://stakeholderwhisperer.com/posts/2014/10/introducing-modelling-by-example).

1. Have conversations with business team and/or stakeholders to discover general requirements of new feature. Keep asking "Can you give me an example?" until the question no longer makes sense.
1. Write scenarios using *ubiquitous language* for each example established through these conversations. [Having trouble? Return to 1.]
1. Write implementations of scenario steps matching ubiquitous language as closely as possible. [Having trouble? Return to 1.]
1. Tests fail.
1. Write app. [Having trouble? Return to 1.]
1. Tests pass.
1. Have conversations with business team and/or stakeholders to discover UI requirements of new feature. Keep asking "Can you give me an example?" until the question no longer makes sense.
1. Re-appropriate scenarios [critical first] for UI examples. [Having trouble? Return to 7.]
1. Adjust implementations of when/then scenario steps to involve user interactions. [Having trouble? Return to 7.]
1. Tests fail.
1. Write UI. [Having trouble? Return to 7.]
1. Tests pass.
1. Take to business team and/or stakeholders. [Not satisfied with functionality? Return to 1. Not satisfied with UI? Return to 7.]
1. Done!
