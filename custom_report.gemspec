# Provide a simple gemspec so you can easily use your enginex
# project in your rails apps through git.
$:.push File.expand_path("../lib", __FILE__)
require 'custom_report/version'

Gem::Specification.new do |s|
  s.name = "custom_report"
  s.files = `git ls-files`.split("\n")
  s.version = "0.0.1"
  s.name                      = "custom_report"
  s.version                   = CustomReport::VERSION
  s.platform                  = Gem::Platform::RUBY
  s.authors                   = [ "Your Name" ]
  s.email                     = [ "your@email.com" ]
  s.homepage                  = "http://yourwebsite.com"
  s.summary                   = "Create CustomReports to make quick customized reports."
  s.description               = "Use CustomReports to get a good quick glipse into your application data."
  s.license		      = "MIT"

  s.required_rubygems_version = "> 1.3.6"

  s.add_dependency "activesupport" , ">= 3.2.8"
  s.add_dependency "rails"         , ">= 3.2.8"

  s.files = `git ls-files`.split("\n")
  s.executables = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
