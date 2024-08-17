# frozen_string_literal: true

require_relative "lib/code0/identities/version"

Gem::Specification.new do |spec|
  spec.name = "code0-identities"
  spec.version = Code0::Identities::VERSION
  spec.authors = ["Dario Pranjic"]
  spec.email = ["dpranjic@code0.tech"]

  spec.summary = "Library to manage external identities"
  spec.homepage = "https://github.com/code0-tech/code0-identities"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/releases"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "httparty", "~> 0.22"
  spec.add_development_dependency "webmock", "~> 3.23.1"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.21"
  spec.add_development_dependency "rubocop-rake", "~> 0.6"
  spec.add_development_dependency "rubocop-rspec", "~> 2.29" # Uncomment to register a new dependency of your gem
  spec.metadata["rubygems_mfa_required"] = "true"
end
