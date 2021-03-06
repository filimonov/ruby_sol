require 'rubygems'
require 'rake'
require 'rdoc/task'
require 'rubygems/package_task'
require 'rspec/core/rake_task'

desc 'Default: run the specs.'
task :default => :spec

# I don't want to depend on bundler, so we do it the bundler way without it
gemspec_path = 'RubySol.gemspec'
spec = begin
  eval(File.read(File.join(File.dirname(__FILE__), gemspec_path)), TOPLEVEL_BINDING, gemspec_path)
rescue LoadError => e
  original_line = e.backtrace.find { |line| line.include?(gemspec_path) }
  msg  = "There was a LoadError while evaluating #{gemspec_path}:\n  #{e.message}"
  msg << " from\n  #{original_line}" if original_line
  msg << "\n"
  puts msg
  exit
end

RSpec::Core::RakeTask.new do |t|
end

desc 'Generate documentation'
RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = spec.name
  rdoc.options += spec.rdoc_options
  rdoc.rdoc_files.include(*spec.extra_rdoc_files)
  rdoc.rdoc_files.include("lib") # Don't include ext folder because no one cares
end

Gem::PackageTask.new(spec) do |pkg|
  pkg.need_zip = false
  pkg.need_tar = false
end

desc "Build gem packages"
task :gems do
  sh "rake  gem RUBY_CC_VERSION=1.8.7:1.9.2"
end