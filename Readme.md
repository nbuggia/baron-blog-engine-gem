#Baron Blog Engine Gem

No one needs another blog engine. This is just a fun side project to play around
with Ruby and a small web-based app. I wanted to create the simplest content 
management engine I could that included all the features I was looking for to 
power my blog. 

There are two parts, the [Baron Blog Engine Gem](https://rubygems.org/gems/baron) 
and the [Baron Blog](https://github.com/nbuggia/baron-blog) project. The gem 
contains the code for routing, HTTP, and the MVC components of a simple blog. 
The blog project instantiates the gem and includes the blog UI templates and 
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