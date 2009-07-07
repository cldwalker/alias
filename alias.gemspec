# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{alias}
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Gabriel Horner"]
  s.date = %q{2009-07-07}
  s.description = %q{Creates aliases for class methods, instance methods, constants, delegated methods and more. Aliases can be easily searched or saved as YAML config files to load later. Custom alias types are easy to create with the DSL Alias provides.  Although Alias was created with the irb user in mind, any Ruby console program can hook into Alias for creating configurable aliases.}
  s.email = %q{gabriel.horner@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    "CHANGELOG.rdoc",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION.yml",
    "lib/alias.rb",
    "lib/alias/console.rb",
    "lib/alias/creator.rb",
    "lib/alias/creators/any_to_instance_method_creator.rb",
    "lib/alias/creators/class_method_creator.rb",
    "lib/alias/creators/class_to_instance_method_creator.rb",
    "lib/alias/creators/constant_creator.rb",
    "lib/alias/creators/instance_method_creator.rb",
    "lib/alias/manager.rb",
    "lib/alias/util.rb",
    "lib/alias/validator.rb",
    "test/alias_test.rb",
    "test/aliases.yml",
    "test/any_to_instance_method_creator_test.rb",
    "test/class_method_creator_test.rb",
    "test/class_to_instance_method_creator_test.rb",
    "test/console_test.rb",
    "test/constant_creator_test.rb",
    "test/creator_test.rb",
    "test/instance_method_creator_test.rb",
    "test/manager_test.rb",
    "test/test_helper.rb",
    "test/util_test.rb",
    "test/validator_test.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://tagaholic.me/alias/}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.2}
  s.summary = %q{Creates, manages and saves aliases for class methods, instance methods, constants, delegated methods and more.}
  s.test_files = [
    "test/alias_test.rb",
    "test/any_to_instance_method_creator_test.rb",
    "test/class_method_creator_test.rb",
    "test/class_to_instance_method_creator_test.rb",
    "test/console_test.rb",
    "test/constant_creator_test.rb",
    "test/creator_test.rb",
    "test/instance_method_creator_test.rb",
    "test/manager_test.rb",
    "test/test_helper.rb",
    "test/util_test.rb",
    "test/validator_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
