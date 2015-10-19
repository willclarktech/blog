---
layout: page
title: willclark.tech
tagline: a work in progress (but that's ok)
---
{% include JB/setup %}

I'm a web developer living in Berlin, previously from London. The main purpose of this blog is to keep an updated record of the steps involved in creating a web application, covering the process—

* from inception to production and beyond,
* from the most abstract overview of the process to incredibly specific suggestions (e.g. what to type in the command line),
* from the perspective of someone interested in every aspect of building a web application (no matter how far things get from programming),
* from the perspective of someone aiming to do everything the right way from the outset.

## Get started

[Start here] with web development steps at the most abstract level. You can navigate to more specific steps from there.

Not sure what this is all about? Read the [mission statement].

## Recent posts

<ul class="posts">
  {% for post in site.posts | sort: '-date' | limit:5 %}
    <li><span>{{ post.date | date_to_string }}</span> &raquo; <a href="{{ BASE_PATH }}{{ post.url }}">{{ post.title }}</a></li>
  {% endfor %}
</ul>

## Hire me!

[Get in touch] if you need a website, or if your existing website needs updating. As I'm building up a portfolio right now my prices are very reasonable and if it's a simple site I can even do it for free. [See my website] for further details and examples of my work.

[Start here]: pages/start-here.html
[mission statement]: general/2015/10/16/mission-statement/
[Get in touch]: mailto:will@willclark.tech
[See my website]: http://willclark.tech