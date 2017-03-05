#Baron Blog Engine Gem

No one needs another blog engine. This is just a side project to play around
with Ruby and a small web-based app. I wanted to create the simplest content 
management engine that included all the features I was looking for to 
power my blog. 

There are two parts, the [Baron Blog Engine Gem](https://rubygems.org/gems/baron) 
and the [Baron Blog](https://github.com/nbuggia/baron-blog) project. The gem 
contains the code for routing, HTTP, and the MVC components of a simple blog. 
The blog project references the gem, includes the blog UI templates and 
content.

## Features

* Publish to Heroku (or similar) using Git
* Easy to customize the look & feel via a common site layout template
* Author posts or custom pages in markdown or HTML
* Organize content into categories
* Several permalink formats are supported, including a custom prefix and several date formats
* 301 or 302 redirects are supported for easy porting from your current blog
* SEO optimized with built-in support for Robots.txt, Google Analytics, Google web master tools
* Fun tech used: Ruby, Rack, RSpec, Bootstrap, Disqus

## Technical Design Notes

cms for wide variety of sites -- media, text blog, photo only. wanted to be able to write in markdown and use this for future projects.

Design objectives:

* Use conventions to simplify code
* Easy to understand, easy to maintain
* Try test driven development.
* Adopt ruby coding desing approaches

