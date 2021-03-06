# -*- encoding: utf-8 -*-
require 'rubygems' unless Object.const_defined?(:Gem)
require File.dirname(__FILE__) + "/lib/alias/version"

Gem::Specification.new do |s|
  s.name        = "alias"
  s.version     = Alias::VERSION
  s.authors     = ["Gabriel Horner"]
  s.email       = "gabriel.horner@gmail.com"
  s.homepage    = "http://tagaholic.me/alias/"
  s.summary = "Creates, manages and saves aliases for class methods, instance methods, constants, delegated methods and more."
  s.description = "Creates aliases for class methods, instance methods, constants, delegated methods and more. Aliases can be easily searched or saved as YAML config files to load later. Custom alias types are easy to create with the DSL Alias provides.  Although Alias was created with the irb user in mind, any Ruby console program can hook into Alias for creating configurable aliases."
  s.required_rubygems_version = ">= 1.3.6"
  s.add_development_dependency 'bacon', '>= 1.1.0'
  s.add_development_dependency 'bacon-bits'
  s.add_development_dependency 'mocha', '~> 0.12.1'
  s.add_development_dependency 'mocha-on-bacon', '~> 0.2.1'
  s.files = Dir.glob(%w[{lib,test}/**/*.rb bin/* [A-Z]*.{txt,rdoc} ext/**/*.{rb,c} **/deps.rip]) + %w{Rakefile .gemspec .travis.yml}
  s.files += Dir.glob('test/*.yml')
  s.extra_rdoc_files = ["README.rdoc", "LICENSE.txt"]
  s.license = 'MIT'
end
