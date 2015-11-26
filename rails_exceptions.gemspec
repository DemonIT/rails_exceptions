$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rails_exceptions/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "rails_exceptions"
  s.version     = RailsExceptions::VERSION
  s.authors     = ["Dmitry Ulyanov"]
  s.email       = ["demon@pglu.pro"]
  s.homepage    = ""
  s.summary     = ""
  s.description = "."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.20"

end
