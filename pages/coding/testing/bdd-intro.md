---
layout: page
title: "BDD Intro"
description: "Introduction to behavior-driven development"
---
{% include JB/setup %}

Broadly speaking, there are two ways people view the role of testing in development. The first is this:

>Testing is something that you do after your development process (or a stage of your development process) is complete. It lets you find bugs you might not have found otherwise, but mostly it's a pain because your application already basically works and testing is this extra thing you're supposed to do.

The other way of looking at it is like this:

>Tests should be written at the start of your development process (or each stage of your development process). They specify what your application should do so that your development process remains focused and you don't end up writing redundant code.

This way of looking at things is known as Test-Driven Development (TDD). For an excellent introduction to TDD and its benefits, I recommend [Harry Percival's Test-Driven Development with Python], which you can read for free online (you can also buy a physical book).

Behavior-driven development (BDD) is a form of TDD, which involves focusing on the features needed of a web application and the scenarios in which those features will be used. For an introduction to BDD, read [the excellent philosophy page on the Python module *behave*] or [this classic post by Dan North].

I'll write more at some point on the reasons I like BDD so much, but for now the main benefits I see are:

1. It keeps you focused on writing code that solves the problem at hand (ie what's important).
2. By using something like natural language (as opposed to traditional programming languages) it breaks you out of the coding mindset when designing features, making it easy for you to design the features you actually want, rather than whatever is convenient or obvious to code.
3. It makes it relatively easy to make changes in your application without unwittingly breaking things. For an extreme example, suppose that you decide your application needs to be rewritten using a different web framework entirely: you can still keep all your behavioral tests!




[Harry Percival's Test-Driven Development with Python]: http://chimera.labs.oreilly.com/books/1234000000754/index.html
[the excellent philosophy page on the Python module *behave*]: https://pythonhosted.org/behave/philosophy.html
[this classic post by Dan North]: http://dannorth.net/introducing-bdd/