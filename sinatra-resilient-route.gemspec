# frozen_string_literal: true

require_relative "lib/sinatra/resilient/route/version"

Gem::Specification.new do |spec|
  spec.name          = "sinatra-resilient-route"
  spec.version       = Sinatra::Resilient::Route::VERSION
  spec.authors       = ["Michael Hale"]
  spec.email         = ["mhale@heroku.com"]

  spec.summary       = "Ensure that sinatra.route is set even when errors are raised in before"
  spec.homepage      = "https://github.com/mikehale/sinatra-resilient-route"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/mikehale/sinatra-resilient-route"
  spec.metadata["changelog_uri"] = "https://github.com/mikehale/sinatra-resilient-route/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
