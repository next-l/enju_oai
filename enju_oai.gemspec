$:.push File.expand_path("lib", __dir__)

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
  s.test_files = Dir["spec/**/*"] - Dir["spec/dummy/log/*"] - Dir["spec/dummy/solr/{data,pids,default,development,test}/*"] - Dir["spec/dummy/tmp/*"]

  #s.add_dependency "enju_biblio", "~> 0.2.0"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "pg"
  s.add_development_dependency "rspec-rails", "~> 4.0"
  s.add_development_dependency "factory_bot_rails"
  #s.add_development_dependency "enju_leaf", "~> 1.2.0"
  #s.add_development_dependency "enju_nii", "~> 0.2.0"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "sunspot_solr", "~> 2.5"
  s.add_development_dependency "resque"
  s.add_development_dependency "vcr"
  s.add_development_dependency "webmock"
  s.add_development_dependency "coveralls", '~> 0.8.23'
  s.add_development_dependency "annotate"
end
