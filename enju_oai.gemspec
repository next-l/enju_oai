$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "enju_oai/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "enju_oai"
  s.version     = EnjuOai::VERSION
  s.authors     = ["Kosuke Tanabe"]
  s.email       = ["nabeta@fastmail.fm"]
  s.homepage    = "https://github.com/next-l/enju_oai"
  s.summary     = "enju_oai plugin"
  s.description = "provide OAI-PMH methods for Next-L Enju"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"] - Dir["spec/dummy/db/*.sqlite3"] - Dir["spec/dummy/log/*"] - Dir["spec/dummy/solr/**/*"] - Dir["spec/dummy/tmp/*"]

  s.add_dependency "enju_biblio", "~> 0.3.0.beta.2"

  s.add_development_dependency "enju_leaf", "~> 1.3.0.beta.2"
  s.add_development_dependency "enju_nii", "~> 0.3.0.beta.1"
  s.add_development_dependency "enju_ndl", "~> 0.3.0.beta.1"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "mysql2"
  s.add_development_dependency "pg"
  s.add_development_dependency "rspec-rails", "~> 3.7"
  s.add_development_dependency "factory_bot_rails"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "sunspot_solr", "~> 2.3"
  s.add_development_dependency "coveralls"
  s.add_development_dependency "vcr", "~> 4.0"
  s.add_development_dependency "webmock"
end
