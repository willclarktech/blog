---
layout: post
title: "Unit testing in Node and Express"
description: "Resources for learning how to unit test middleware in Node (node.js) and Express (express.js). Mocha, Chai, Sinon."
category: testing
tags: [node.js, express.js, unit testing, web development]
---
{% include JB/setup %}

I've started learning Express.js, and it's been surprisingly difficult to find decent resources on how to do proper unit tests for route handlers. There are a lot of tutorials, blogs and Stack Overflow answers on how to test server responses, and a lot of these say that what they are doing is "unit testing". But real unit tests shouldn't require a server at all, they should simply test the behaviour of individual functions. Otherwise a lot of what you're testing is just the Express framework. Of course, server response tests can be useful for testing, for example, that you have plugged your functions into the Express framework in the right way, but they're no replacement for unit tests for two reasons:

1. Unit tests are by their nature very fine-grained, so they give you very specific information about the source of a test failure.
2. Testing against a server takes a lot longer than simply running tests simply a function. On a small project with few tests the difference may not be noticeable, but the more tests you have the bigger the difference becomes, and every time you run tests against the server when all you need are unit tests adds wasted time.

If you're interested in testing HTTP responses against a server, by far the best post I've come across is [this one by David Beath](https://davidbeath.com/posts/testing-http-responses-in-nodejs.html). He doesn't make the mistake of calling them "unit tests", and he takes you through the process of setting up a test suite in Node.js, including installing relevant dependencies and setting up a test server. Having said that, it's for Node.js in general rather than Express specifically, so I had to make a couple of adjustments (like passing my Express app to the test server rather than David's anonymous function).

As for unit tests, [this presentation by Morris Singer](https://www.youtube.com/watch?v=BwNMUVzo3vs) makes the case for proper unit tests vs only server response tests, and gives a clear overview of how to make the switch to unit tests. Unit testing is difficult in Node/Express because of the aynchronous nature of code being tested. Morris's solution is to use promises in middleware, which can help you to avoid—among other problems—conditions in your unit tests. I highly recommend this video.

If you want more detail on how to actually write unit tests with promises using Mocha, Chai assertions (and Sinon stubs/spies), [Jani Hartikainen has an absolutely killer post](http://www.sitepoint.com/promises-in-javascript-unit-tests-the-definitive-guide/) which shows you how to write succinct, natural-sounding unit tests involving promises.
