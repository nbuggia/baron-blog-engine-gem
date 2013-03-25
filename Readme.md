#Baron Blog Engine Gem

A minimalist, yet fully-featured, blog engine for developers.

This project is only the blog engine gem, if you want to play with your own 
blog, you should use this project, which includes the client:

**https://github.com/nbuggia/baron-blog**

##How Does it Work?

Here's a quick overview of how the whole thing comes together. 

There are two parts to this blog, the **Baron Blog Engine Gem** and the 
**Baron Blog** project. The blog engine gem contains all the code for the data 
model and the view controllers, which is conveniently packaged up into a gem 
for easy distribution (I might change that in the future to make it easier to 
hack). The Baron Blog project contains all of the views, and the assets (CSS, 
images, articles, etc). It references the blog engine gem.

**Baron Blog Engine Gem**

All of the source code for this is in a single code file (./lib/baron.rb).

Project structure:

	├── LICENSE								
	├── Rakefile							rake test, rake install
	├── Readme.md							you are reading this document now...
	├── VERSION
	├── lib/
	│   └── baron.rb						all the source code for the gem
	├── pkg/
	│   └── baron-1.0.0.gem					byte-code compiled gem (I think)
	└── spec/								unit tests using RSpec
	    ├── baron_article_spec.rb			article data model tests
	    ├── baron_blog_engine_spec.rb		BlogEngine class tests
	    ├── baron_spec.rb					end-to-end tests
	    ├── sample_data/					sample data for testing
	    └── spec_helper.rb

* Baron::BlogEngine - handles the main application loop. It handles building the
right page for every given route. It also contains all the logic for where all
the files are stored.

* Baron::PageController - uses Ruby's ERB library to render the template pages 
with the variable's from the Baron::BlogEngine. Most pages get rendered twice,
the first time we render the partial page (e.g. an article data model into the 
article rhtml template) and the second time we render the article.rhtml results
into the site layout template (./themes/theme/templates/layout.rhtml)

* Baron::Article - the data model for a single article.

##Thanks

While writing this blog engine, I barrowed a lot of code and design approaches
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