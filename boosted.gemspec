# frozen_string_literal: true

require_relative "lib/boosted/version"

Gem::Specification.new do |spec|
  spec.name = "boosted-rails"
  spec.version = Boosted::VERSION
  spec.authors = ["Juan Aparicio"]
  spec.email = ["apariciojuan30@gmail.com"]

  spec.summary = "Set of modules to boost your Ruby on Rails development"
  spec.homepage = "https://github.com/gogrow-dev/boosted"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/gogrow-dev/boosted"
  spec.metadata["rubygems_mfa_required"] = "true"

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

  spec.add_dependency "rails", ">= 6.0", "< 8.0"
  spec.add_dependency "zeitwerk", ">= 2.4"
end
