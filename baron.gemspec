# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "baron"
  s.version = "1.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nathan Buggia"]
  s.date = "2013-03-18"
  s.description = "What's in the box: (1) Publish to Heroku using Git (2) Author articles in markdown (3) Article categories (4) Multiple permalink formats supported (5) Redirects (6) Advanced SEO optimizations and Google Analytics/ Webmaster Tools support. Uses Rack, RSpec, Bootstrap, JQuery, Disqus, Thin"
  s.email = "nbuggia@gmail.com"
  s.extra_rdoc_files = [
    "LICENSE"
  ]
  s.files = [
    "LICENSE",
    "Rakefile",
    "Readme.md",
    "VERSION",
    "baron.gemspec",
    "lib/baron.rb",
    "spec/baron_article_spec.rb",
    "spec/baron_blog_engine_spec.rb",
    "spec/baron_spec.rb",
    "spec/sample_data/.gitignore",
    "spec/sample_data/Gemfile",
    "spec/sample_data/README.md",
    "spec/sample_data/Rakefile",
    "spec/sample_data/articles/favorites/1916-01-01-the-road-not-taken.txt",
    "spec/sample_data/articles/north of boston/1914-01-01-the-pasture.txt",
    "spec/sample_data/articles/north of boston/1914-01-02-mending-wall.txt",
    "spec/sample_data/articles/north of boston/1914-01-03-the-death-of-the-hired-man.txt",
    "spec/sample_data/articles/north of boston/1914-01-04-the-mountain.txt",
    "spec/sample_data/articles/north of boston/1914-01-05-A-Hundred-callers.txt",
    "spec/sample_data/articles/other authors/1909-01-02-If.txt",
    "spec/sample_data/config.ru",
    "spec/sample_data/images/robert-frost-small.png",
    "spec/sample_data/images/robert-frost.png",
    "spec/sample_data/pages/about.rhtml",
    "spec/sample_data/resources/feed.rss",
    "spec/sample_data/resources/redirects.txt",
    "spec/sample_data/resources/robots.txt",
    "spec/sample_data/themes/typography/css/app.css",
    "spec/sample_data/themes/typography/css/bootstrap-responsive.css",
    "spec/sample_data/themes/typography/css/bootstrap-responsive.min.css",
    "spec/sample_data/themes/typography/css/bootstrap.css",
    "spec/sample_data/themes/typography/css/bootstrap.min.css",
    "spec/sample_data/themes/typography/img/github.png",
    "spec/sample_data/themes/typography/img/glyphicons-halflings-white.png",
    "spec/sample_data/themes/typography/img/glyphicons-halflings.png",
    "spec/sample_data/themes/typography/img/instagram.png",
    "spec/sample_data/themes/typography/js/bootstrap.js",
    "spec/sample_data/themes/typography/js/bootstrap.min.js",
    "spec/sample_data/themes/typography/js/image_alt.js",
    "spec/sample_data/themes/typography/js/read_later.js",
    "spec/sample_data/themes/typography/templates/archives.rhtml",
    "spec/sample_data/themes/typography/templates/article.rhtml",
    "spec/sample_data/themes/typography/templates/category.rhtml",
    "spec/sample_data/themes/typography/templates/error.rhtml",
    "spec/sample_data/themes/typography/templates/home.rhtml",
    "spec/sample_data/themes/typography/templates/layout.rhtml",
    "spec/spec_helper.rb"
  ]
  s.homepage = "https://github.com/nbuggia/baron-blog-engine-gem"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.25"
  s.summary = "Minimalist, yet full-featured, blog engine in 400 lines of code."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_runtime_dependency(%q<rack>, [">= 0"])
    else
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<rack>, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<rack>, [">= 0"])
  end
end

