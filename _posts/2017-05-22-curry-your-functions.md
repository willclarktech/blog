---
title: "Curry your functions"
description: "Functions in JavaScript are more fun if you curry them by default."
category: tech
tags: [javascript, functional programming]
---

Currying is the process of taking a function which takes multiple arguments all at once, and spitting out a higher-order function which allows you to apply each argument one at a time, because it only takes one argument and returns a (possibly higher-order function) which also only takes one argument etc.

For example:
```js
function(a, b, c) {
  console.log(a, b, c)
}
// Curried
function(a) {
  return function(b) {
    return function(c) {
      console.log(a, b, c)
    }
  }
}
```
Here's the same thing with the cleaner arrow function syntax:
```js
(a, b, c) => {
  console.log(a, b, c)
}
// Curried
a => b => c => {
  console.log(a, b, c)
}
```

There's a great explanation of the difference between currying and partial application on [2ality](http://2ality.com/2011/09/currying-vs-part-eval.html).

## Pre-curried functions in Elm

In [Elm](http://elm-lang.org/), the functional programming language which compiles to JavaScript, all functions are curried by default. So this function
```Elm
add a b = a + b
```
can be called with just one argument to return another function that also takes one argument.
```Elm
add2 = add 2
result1 = add2 3 -- 5
result2 = add2 7 -- 9
```

## Back to JavaScript

Once you've played around with Elm for a while, you start wondering why you *wouldn't* want your functions to be curried. The main benefit is that it makes partial application cleaner and more manoeuvrable. Compare:
```js
const fn = (a, b, c) => {
  console.log(a, b, c)
}
// Option 1: clunky
const partiallyApplied = fn.bind(null, 'first', 'second')
// Option 2: inflexible, obscures relationships
const partiallyAppliedWithOneArgument = (b, c) => fn('first', b, c)
const partiallyAppliedWithTwoArguments = c => fn('first', 'second', c)
```
versus
```js
const fn = a => b => c => {
  console.log(a, b, c)
}
// Vs. Option 1: succinct and clean
const partiallyApplied = fn('first')('second')
// Vs. Option 2: flexible, relationships can be made clear
const partiallyAppliedWithOneArgument = fn('first')
const partiallyAppliedWithTwoArguments = partiallyAppliedWithOneArgument('second')
```
The other benefit is that sometimes there are reasons to switch from an uncurried function to a curried one, e.g. if you realise that every time it will be used it will need to involve partial application, so the curried form is just more convenient. But there's basically no situation I can think of where you'd be pushed to switch from a curried form to an uncurried form. So precurrying all of your functions by default means you can avoid costly rewrites later on.

(Often 3rd party libraries, e.g. [Redux](http://redux.js.org/) will require you to supply an uncurried function, which is the only situation I've thought of where you might have to rewrite a curried function. But it would have to be a pretty weird situation for you not to be aware of these requirements when writing the function in the first place.)
