# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{alias}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Gabriel Horner"]
  s.date = %q{2009-01-20}
  s.description = %q{Provides aliases for class names, class methods, instance methods and more. Mainly for console use.}
  s.email = %q{gabriel.horner@gmail.com}
  s.files = ["Rakefile", "README.rdoc", "LICENSE.txt", "aliases.yml.example", "lib/alias", "lib/alias/class_method_creator.rb", "lib/alias/constant_creator.rb", "lib/alias/core_extensions.rb", "lib/alias/creator.rb", "lib/alias/instance_method_creator.rb", "lib/alias/manager.rb", "lib/alias/method_creator_helper.rb", "lib/alias.rb", "test/alias_test.rb", "test/aliases.yml", "test/core_extensions_test.rb", "test/creator_test.rb", "test/manager_test.rb", "test/method_creator_helper_test.rb", "test/test_helper.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/cldwalker/alias}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Provides aliases for class names, class methods, instance methods and more. Mainly for console use.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
