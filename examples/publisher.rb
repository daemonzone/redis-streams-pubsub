#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "redis-streams-pubsub"

# Create a publisher client
publisher = Redis::Streams::PubSub::Client.new(url: "redis://127.0.0.1:6379")

# Topic to publish to
topic = "notifications"

# Publish some messages
puts "Publishing messages to '#{topic}' topic..."

5.times do |i|
  message = {
    id: i + 1,
    type: "notification",
    message: "Hello from publisher!",
    timestamp: Time.now.to_i
  }

  publisher.publish(topic, message)
  puts "Published: #{message.inspect}"
  
  sleep 1
end

puts "\nAll messages published!"
