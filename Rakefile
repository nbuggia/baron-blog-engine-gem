require 'rubygems'
require 'rake'

##
# Create gem

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "baron"
    gem.summary = %Q{Hacked version of the toto blog engine}
    gem.description = %Q{Hacked version of the toto blog engine.}
    gem.email = "nbuggia@gmail.com"
    gem.homepage = "https://github.com/nbuggia/baron"
    gem.authors = ["Nathan Buggia"]
    gem.add_development_dependency "rspec"
    gem.add_dependency "builder"
    gem.add_dependency "rack"
    gem.add_dependency "rdiscount"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

##
# Run RSpec tests

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)


task :default => :test
task :test => [:check_dependencies, :spec]
