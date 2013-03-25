require 'rubygems'
require 'rake'

##
# Create gem

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "baron"
    gem.summary = %Q{Minimalist, yet full-featured, blog engine.}
    gem.description = %Q{What's in the box: (1) Publish to Heroku using Git (2) Author articles in markdown (3) Article categories (4) Multiple permalink formats supported (5) Redirects (6) Advanced SEO optimizations and Google Analytics/ Webmaster Tools support. Uses Rack, RSpec, Bootstrap, JQuery, Disqus, Thin}
    gem.email = "nbuggia@gmail.com"
    gem.homepage = "https://github.com/nbuggia/baron-blog-engine-gem"
    gem.authors = ["Nathan Buggia"]
    gem.add_development_dependency "rspec"
    gem.add_dependency "rack"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install with: sudo gem install jeweler"
end

##
# Run RSpec tests

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task :default => :test
task :test => [:check_dependencies, :spec]
