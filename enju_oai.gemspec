$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "enju_oai/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "enju_oai"
  s.version     = EnjuOai::VERSION
  s.authors     = ["Kosuke Tanabe"]
  s.email       = ["tanabe@mwr.mediacom.keio.ac.jp"]
  s.homepage    = "https://github.com/nabeta/enju_oai"
  s.summary     = "enju_oai plugin"
  s.description = "provide OAI-PMH methods for Next-L Enju"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 3.2"
  s.add_dependency "enju_core"
  s.add_dependency "mobile-fu"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "enju_biblio"
  s.add_development_dependency "enju_library"
  s.add_development_dependency "enju_manifestation_viewer"
  s.add_development_dependency "sunspot_solr", "~> 2.0.0.pre.120720"
end
