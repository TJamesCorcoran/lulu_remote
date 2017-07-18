$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "lulu_remote/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "lulu_remote"
  s.version     = LuluRemote::VERSION
  s.authors     = ["T James Corcoran"]
  s.email       = ["tjamescorcoran@gmail.com"]
  s.homepage    = "https://github.com/tjamescorcoran"
  s.summary     = "Tools for interacting with Lulu.com"
  s.description = ""
  s.license     = ""

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

#  s.add_dependency "mechanize",  "2.7"
  s.add_dependency "launchy"               # gives us save_and_open_page()
  s.add_dependency "selenium-webdriver", "2.53.4"
  s.add_dependency "capybara"
  s.add_dependency "capybara-webkit"
  s.add_dependency "capybara-screenshot"

  
end
