# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{alias}
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Gabriel Horner"]
  s.date = %q{2009-01-16}
  s.description = %q{Provides aliases for class names, class methods, instance methods and more. Mainly for console use.}
  s.email = %q{gabriel.horner@gmail.com}
  s.files = ["README.markdown", "LICENSE.txt", "{bin,lib,test}/**/*"]
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
