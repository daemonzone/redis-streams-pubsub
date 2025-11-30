# redis-streams-pubsub.gemspec
# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "redis-streams-pubsub"
  spec.version       = "0.1.0"
  spec.summary       = "Pub/Sub style API on top of Redis Streams"
  spec.description   = "Simplifies Redis Streams by offering publish/subscribe helpers."
  spec.authors       = ["Davide V."]
  spec.files         = Dir["lib/**/*"]
  spec.required_ruby_version = ">= 3.0"
  spec.add_dependency "redis-client", ">= 0.26"
  spec.metadata["rubygems_mfa_required"] = "true"
end

