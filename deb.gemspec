$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "deb/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "deb"
  s.version     = Deb::VERSION
  s.authors     = ["Boris Nadion"]
  s.email       = ["boris@astrails.com"]
  s.homepage    = "https://github.com/astrails/deb"
  s.summary     = "Double Entry Bookkeeping for Rails"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.markdown"]
  s.license = 'MIT'

  s.add_dependency "rails", ">= 4"
  s.add_dependency "docile"

  s.add_development_dependency("sqlite3")
  s.add_development_dependency("rspec")
  s.add_development_dependency("rspec-rails")
  s.add_development_dependency("minitest")
end
