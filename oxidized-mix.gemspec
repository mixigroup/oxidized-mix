# frozen_string_literal: true

require_relative 'lib/oxidized_mix/version'

Gem::Specification.new do |spec|
  spec.name = 'oxidized-mix'
  spec.version = OxidizedMix::VERSION
  spec.authors = ['Shintaro Kojima']
  spec.email = ['goodies@codeout.net']

  spec.summary = 'Oxidized Mix'
  spec.description = 'Custom Oxidized for MIXI operation which covers both oxidized and oxidized-script'
  spec.homepage = 'https://github.com/mixigroup/oxidized-mix'
  spec.required_ruby_version = '>= 2.7.0'

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"
  #
  # spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'oxidized', '~> 0.28'

  spec.add_runtime_dependency 'oxidized-script', '~> 0.7'

  spec.add_development_dependency 'rubocop', '~> 1.44'
end
