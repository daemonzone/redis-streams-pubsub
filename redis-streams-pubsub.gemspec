# frozen_string_literal: true

require_relative "lib/redis/streams/pubsub/version"

Gem::Specification.new do |spec|
  spec.name          = "redis-streams-pubsub"
  spec.version       = Redis::Streams::PubSub::VERSION
  spec.summary       = "A Redis Streams pub/sub client for Ruby"
  spec.description   = "Basic Redis Streams wrapper with consumer groups for pub/sub"
  spec.authors       = ["Davide Villani"]
  spec.email         = ["daemonzone@users.noreply.github.com"]
  spec.licenses      = ["MIT"]
  spec.homepage      = "https://github.com/daemonzone/redis-streams-pubsub"
  spec.metadata      = {
    "source_code_uri" => "https://github.com/daemonzone/redis-streams-pubsub",
    "changelog_uri" => "https://github.com/daemonzone/redis-streams-pubsub/CHANGELOG.md",
    "rubygems_mfa_required" => "true"
  }

  spec.required_ruby_version = ">= 3.0"
  spec.files = Dir["lib/**/*", "README.md", "CHANGELOG.md"]
  spec.add_dependency "redis-client", "~> 0.26"
end
