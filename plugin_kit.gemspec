# frozen_string_literal: true

require_relative "lib/cocov/plugin_kit/version"

Gem::Specification.new do |spec|
  spec.name = "cocov_plugin_kit"
  spec.version = Cocov::PluginKit::VERSION
  spec.authors = ["Victor Gama"]
  spec.email = ["hey@vito.io"]
  spec.license = "GPL-3.0-only"

  spec.summary = "PluginKit implements helpers for running Cocov plugins"
  spec.description = spec.summary
  spec.homepage = "https://github.com/cocov-ci/plugin_kit"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["rubygems_mfa_required"] = "true"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features|support)/|\.(?:git|travis|circleci)|appveyor|example.rb|docker-compose.yaml)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
