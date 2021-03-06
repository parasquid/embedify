# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "embedify"
  s.version = "0.7.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tristan Gomez"]
  s.date = "2012-07-08"
  s.description = "Embedify is a ruby gem that parses and returns an\n    embeddable version of a page, similar to how Facebook fetches and retrieves\n    page data when posting a link."
  s.email = "tristan.gomez+embedify@gmail.com"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    ".rvmrc",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "embedify.gemspec",
    "examples/embedify_server/Gemfile",
    "examples/embedify_server/Gemfile.lock",
    "examples/embedify_server/Rakefile",
    "examples/embedify_server/config.ru",
    "examples/embedify_server/lib/embedify_server.rb",
    "examples/embedify_server/lib/views/index.erb",
    "lib/embedify.rb",
    "test/helper.rb",
    "test/test_embedify.rb"
  ]
  s.homepage = "http://github.com/parasquid/embedify"
  s.licenses = ["LGPLv3"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "parses and returns an embeddable version of a page"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>, ["~> 1.5.0"])
      s.add_runtime_dependency(%q<hashie>, [">= 0"])
      s.add_runtime_dependency(%q<faraday>, [">= 0"])
      s.add_runtime_dependency(%q<faraday_middleware>, [">= 0"])
      s.add_runtime_dependency(%q<hashie>, [">= 0"])
      s.add_runtime_dependency(%q<addressable>, [">= 0"])
      s.add_runtime_dependency(%q<fastimage>, [">= 0"])
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
    else
      s.add_dependency(%q<nokogiri>, ["~> 1.5.0"])
      s.add_dependency(%q<hashie>, [">= 0"])
      s.add_dependency(%q<faraday>, [">= 0"])
      s.add_dependency(%q<faraday_middleware>, [">= 0"])
      s.add_dependency(%q<hashie>, [">= 0"])
      s.add_dependency(%q<addressable>, [">= 0"])
      s.add_dependency(%q<fastimage>, [">= 0"])
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<nokogiri>, ["~> 1.5.0"])
    s.add_dependency(%q<hashie>, [">= 0"])
    s.add_dependency(%q<faraday>, [">= 0"])
    s.add_dependency(%q<faraday_middleware>, [">= 0"])
    s.add_dependency(%q<hashie>, [">= 0"])
    s.add_dependency(%q<addressable>, [">= 0"])
    s.add_dependency(%q<fastimage>, [">= 0"])
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
  end
end

