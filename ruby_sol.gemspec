# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name    = 'ruby_sol'
  s.version = '0.0.1'
  s.platform = Gem::Platform::RUBY
  s.authors  = ['MF', 'Jacob Henry', 'Stephen Augenstein', "Joc O'Connor"]
  s.email    = []
  s.homepage = 'http://github.com/filimonov/ruby_sol'
  s.summary = 'Based on RubySol reader/write of Flash Player's .sol files'

  s.files         = Dir[*['README.rdoc', 'ruby_sol.gemspec', 'Rakefile', 'lib/**/*.rb', 'spec/**/*.{rb,bin,opts}']]
  s.test_files    = Dir[*['spec/**/*_spec.rb']]
  s.extensions    = Dir[*["ext/**/extconf.rb"]]
  s.require_paths = ["lib"]

  s.has_rdoc         = true
  s.extra_rdoc_files = ['README.rdoc']
  s.rdoc_options     = ['--line-numbers', '--main', 'README.rdoc']
end