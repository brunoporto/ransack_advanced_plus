$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ransack_advanced_plus/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ransack_advanced_plus"
  s.version     = RansackAdvancedPlus::VERSION
  s.authors     = ["Bruno Porto","David Brusius"]
  s.email       = ["brunotporto@gmail.com","brusiusdavid@gmail.com"]
  s.homepage    = ""
  s.summary     = "Ransack advanced query mode with some additional features"
  s.description = "Ransack advanced query mode with some additional features"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency 'rails', ['>= 3.2.6','< 5']
  s.add_dependency 'ransack', '~> 1.7.0', '>= 1.7.0'
end
