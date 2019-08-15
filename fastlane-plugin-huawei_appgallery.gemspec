# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/huawei_appgallery/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-huawei_appgallery'
  spec.version       = Fastlane::HuaweiAppgallery::VERSION
  spec.author        = 'Arne Kaiser'
  spec.email         = 'onkelarne@gmail.com'

  spec.summary       = 'Plugin to deploy an app to the Huawei AppGallery'
  spec.homepage      = "https://github.com/arnekaiser/fastlane-plugin-huawei_appgallery"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  # Don't add a dependency to fastlane or fastlane_re
  # since this would cause a circular dependency

  # spec.add_dependency 'your-dependency', '~> 1.0.0'

  spec.add_development_dependency('pry')
  spec.add_development_dependency('bundler')
  spec.add_development_dependency('rspec')
  spec.add_development_dependency('rspec_junit_formatter')
  spec.add_development_dependency('rake')
  spec.add_development_dependency('rubocop', '0.49.1')
  spec.add_development_dependency('rubocop-require_tools')
  spec.add_development_dependency('simplecov')
  spec.add_development_dependency('fastlane', '>= 2.128.1')
end
