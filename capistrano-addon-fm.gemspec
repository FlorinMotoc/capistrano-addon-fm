# frozen_string_literal: true

require_relative "lib/capistrano/addon/fm/version"

Gem::Specification.new do |spec|
  spec.name = "capistrano-addon-fm"
  spec.version = Capistrano::Addon::Fm::VERSION
  spec.authors = ["Florin Motoc"]
  spec.email = ["gems@mflorin.com"]

  spec.summary = "capistrano addon - generic tasks"
  spec.description = "capistrano addon - generic tasks - by FlorinMotoc"
  spec.homepage = "https://github.com/FlorinMotoc/capistrano-addon-fm"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/FlorinMotoc/capistrano-addon-fm/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "capistrano", "~> 3.0"

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
