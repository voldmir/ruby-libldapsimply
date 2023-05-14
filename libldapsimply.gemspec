# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require_relative "lib/libldapsimply/version"

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = "libldapsimply"
  s.version = LIBLDAPSIMPLY::VERSION
  s.authors = ["Vladimir Savchenko"]
  s.email = ["voldmir@mail.ru"]
  s.description = "Library wrapper C libldapgss"
  s.extra_rdoc_files = ["README.md"]
  s.files = Dir["{lib}/**/*"] + ["README.md"]
  s.homepage = "https://github.com/voldmir/libldapsimply"
  s.license = "GPL-3.0"
  s.summary = "Library for LDAP."
  s.metadata["rubygems_mfa_required"] = "true"
  s.required_ruby_version = ">= 2.5.0"
end
