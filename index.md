---
layout: page
title: willclark.tech
tagline: a work in progress (but that's ok)
---
{% include JB/setup %}

## Getting started

[Start here] with web development steps at the most abstract level. You can navigate to more specific steps from there.

Not sure what this is all about? Read the [mission statement].

## Recent posts

<ul class="posts">
  {% for post in site.posts | sort: '-date' | limit:5 %}
    <li><span>{{ post.date | date_to_string }}</span> &raquo; <a href="{{ BASE_PATH }}{{ post.url }}">{{ post.title }}</a></li>
  {% endfor %}
</ul>

## Hire me!

[Get in touch] if you need a website, or if your existing website needs updating. As I'm building up a portfolio right now my prices are very reasonable and if it's a simple site I can even do it for free. See [my website] for further details and examples of my work.

[Start here]: pages/start-here.html
[mission statement]: general/2015/10/16/mission-statement/
[Get in touch]: mailto:will@willclark.tech
[my website]: http://willclark.tech