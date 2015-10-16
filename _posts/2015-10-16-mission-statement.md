---
layout: post
title: "Mission statement"
description: "Specifies the point of this blog"
category: general
tags: [Berlin, best practices, general, German, web development]
---
{% include JB/setup %}

Some of this blog will cover things to do with Berlin and maybe German language tips as and when I come across something especially useful. However, the main purpose of this blog is to keep an updated record of the steps involved in creating a web application, covering the process—

* from inception to production and beyond,
* from the most abstract overview of the process to incredibly specific suggestions (e.g. what to type in the command line),
* from the perspective of someone interested in every aspect of building a web application (no matter how far things get from programming),
* from the perspective of someone aiming to do everything the right way from the outset.

On that last point, the way I learned programming was very piecemeal, starting in the middle. There have been (and continue to be) many occasions where I learn something that I wish I'd learned much earlier. I'm not talking about things like libraries, which you might discover and wish you'd had earlier because they save you a lot of time. In order to use a library you generally need to learn the core tools first. I'm talking instead about situations where the addition of a tool just makes the way *you* do things better in a more general way.

An example: when I started [learning Python], I wish somebody had told me to learn and use [virtualenv] before even starting a Python learning project. And when I finally discovered and started using virtualenv I wish somebody had told me immediately to learn and use [virtualenvwrapper] before even making a virtual environment. virtualenvwrapper doesn't really improve the functionality of virtualenv, it improves the way you do things, because all of your virtual environments are now arranged conveniently.

When it comes to building a web application, if you aim to do everything right from the outset you will inevitably fail in that aim, but I don't think that means it's best not to aim for it at all. Just because you can reliably predict that a norm will be violated, there's no reason to think the norm therefore brings no broader value.

To be clear, I'm not advocating a [waterfall] methodology to web development. The best way to build a web application almost certainly involves leaving many things open at the start, and *not* having ideas about how things should be that aren't open to abrupt change in the light of new and unpredictable information. Likewise, the steps proposed here will not be set in stone, they're just the steps that I plan to use when I start my next project. And if I discover something during the course of that project that changes how I view things here, then I'll update the steps and do things differently in the following project (and hopefully explain that decision in a post here).

Of course, I don't consider myself to have discovered the perfect set of steps involved in the creation of a web application. I know I have a lot to discover, partly because I'm still relatively near the start of this journey in web development and there's a lot I don't know, and partly because new tools keep being created which improve things. A large part of it is also probably down to personal preference. Still, hopefully this will be helpful for people whose preferences are somewhat like mine, and I'll also use it myself to refer back to.

Part of the inspiration for this blog was [this post by levels.io] which gave me an invaluable overview of the process of building a web-based product. As a self-taught developer it can be very hard to be confident that you're doing things to an acceptable standard or that you're not missing tools that any professionally-trained developer would know to use. For anyone just getting started with web development, this blog will list tools that I think you should be using. For anyone further along with web development than me, please let me know if you think I've missed something out or if you think any of my steps can be improved!

P.S. Hopefully this blog will be more successful than [my last attempt at a blog]...

[learning Python]: http://learnpythonthehardway.org/
[virtualenv]: https://virtualenv.pypa.io/
[virtualenvwrapper]: https://virtualenvwrapper.readthedocs.org/
[waterfall methodology]: http://www.base36.com/2012/12/agile-waterfall-methodologies-a-side-by-side-comparison/
[this post by levels.io]: https://levels.io/how-i-build-my-minimum-viable-products/
[my last attempt at a blog]: http://philosophicatly.blogspot.de/