#Baron Blog Engine Gem

A full-featured, yet minimalist, blog engine for developers

I know what you're thinking, the world doesn't need another Ruby blog 
engine. And, okay, you're right, however Baron is a little bit different from
all the others in that it is a lot more full-featured then the other options,
but still only a scant 400 lines of easy-to-ready code.

**Features**
* Publish to heroku (or similar PaaS) using Git
* Author articles or custom pages in markdown, text or HTML
* Article categories supported by simply putting articles in a folder
* Many permalink formats are supported, including a custom prefix and several 
date formates
* 301 or 302 redirects are support for easy porting from your current blog
* SEO optimized with built-in support for Robots.txt, Google Analytics, Google 
web master tools
* Easy to customize the look & feel via a common site layout template
* Frameworks used: Rack, RSpec, Bootstrap, JQuery, Disqus, Thin

##Quick Start

To use the baron blog, go to the client project and follow the instructions 
there. This project holds the source for the engine gem.

TODO - insert link to client project when ready...

##Next Steps

I wrote this as an excuse to learn a handful of new techologies and approaches, 
like Ruby and TDD. There are an ambitious set of features I'd like to add that 
each align to something else I would like to learn:

* Themes - I'm designing 3-4 fancy, shmancy themes to try out this new 'flat'
and minimalist thing everyone's excited about. Also a good excuse to digg into
HTML5, CSS3, JQuery, Instagram's API and a few other things.

* Pre-rendering - the platform nerd in me doesn't understand why the whole 
blog isn't pre-rendered at deploy time so heroku just serves static HTML and
assets (a la <a href="https://github.com/mojombo/jekyll">Jekyll</a>)

* JavaScript Comments - the blog engine currently uses Disqus for comments,
which is free and cool, but I hate letting other people own my data. I want 
to build something similar to Disqus ontop of 
<a href="https://www.parse.com/">Parse</a> / 
<a href="https://github.com/documentcloud/backbone">Backbone</a> and make it 
really easy to use

* Simple Plugin Model - I've always wanted to write a plug-in model. I tried
to write one in C++ in college and was only able to do static linking (lame). I
think an inturpretted language will make it much easier, right?

##How Does it Work?

Here's a quick overview of how the whole thing comes together. 

First, there are two parts to this blog, there is this project 
**Baron Blog Engine Gem** and the **Baron Blog** project. The blog engine gem 
contains all the code for the data model and the view controllers, which is
conveniently packaged up into a gem for easy distribution (I might change that
in the future to make it easier to hack). The Baron Blog project contains all
of the views, and the assets (CSS, images, articles, etc). It references the
blog engine gem.

**Baron Blog Engine Gem**

All of the source code for this is in a single code file (./lib/baron.rb).

Project structure:

	├── LICENSE								
	├── Rakefile							rake test, or rake install
	├── Readme.md							you are reading this document now...
	├── VERSION
	├── lib/
	│   └── baron.rb						all the source code for the gem
	├── pkg/
	│   └── baron-1.0.0.gem					byte-code compiled gem (I think)
	└── spec/								unit tests using RSpec
	    ├── baron_article_spec.rb			article data model tests
	    ├── baron_blog_engine_spec.rb		::BlogEngine class tests
	    ├── baron_spec.rb					end-to-end tests
	    ├── sample_data/					sample data for testing
	    └── spec_helper.rb

* Baron::BlogEngine - handles the main application loop. It handles bulding the
right page for every given route. It also contains all the logic for where all
the files are stored.

* Baron::PageController - uses Ruby's ERB library to render the template pages 
with the variable's from the Baron::BlogEngine. Most pages get rendered twice,
the first time we render the partial page (e.g. an article data model into the 
article rhtml template) and the second time we render the article.rhtml results
into the site layout template (./themes/theme/templates/layout.rhtml)

* Baron::Article - the data model for a single article.

The tests in the (./spec) folder provide many more details on the specifics

**Baron Blog**

Project structure:

		├── Gemfile
		├── Rakefile
		├── articles/							place your published articles here
		│   ├── 2012-11-09-sample-1.txt
		│   └── category/						creating folders puts these articles in a category
		│       ├── 1909-01-02-sample-2.txt
		│       └── 1916-01-01-sample-3.txt
		│   ├── another category/				spaces in folder names will be replaces with '-'s
		├── config.ru							configure features of the blog here
		├── downloads/							files in here are publicly accessible	
		├── drafts/								place for your unfinished articles
		├── images/								images in here are publicly accessible
		├── pages/								you can create custom pages in here
		│   └── about.rhtml
		├── resources/							
		│   ├── feed.rss						your rss feed's rendering template
		│   ├── redirects.txt					list of redirects the blog will process
		│   └── robots.txt						your robots.txt file
		└── themes/
		    └── my-theme/						each theme has the same folder structure
		        ├── css/
		        ├── img/
		        ├── js/
		        └── templates/					rhtml rendering templates for each page type

TODO - I'll update this with more detail once I've posted the Baron Blog project to github

##License

This software is licensed under the MIT Software License

Copyright (c) 2013 Nathan Buggia

Permission is hereby granted, free of charge, to any person obtaining a copy of 
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished to do 
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all 
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
SOFTWARE.

##Thanks

While writing this blog engine, I barrowed a lot of code and design approches
from the Toto project by Cloudhead and the Scanty project by Adam Wiggins. The
primary purpose of this project was a learning one for me, and both of these
folks provided a lot of good code an examples. I'm not sure how much code or 
design awesomeness one needs to use before they are obligated to include their 
license, so I'm included a link to each of them just in case (and thank you 
both for your awesomeness!)

Toto
 - URL: https://github.com/cloudhead/toto
 - Author: http://cloudhead.io/ (Alexis Sellier)
 - License: https://github.com/cloudhead/toto/blob/master/LICENSE

Scanty
 - URL: https://github.com/adamwiggins/scanty
 - Author: http://about.adamwiggins.com/ (Adam Wiggins)