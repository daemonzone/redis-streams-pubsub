#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "redis-streams-pubsub"

# Use a shorter alias
Client = Redis::Streams::PubSub::Client

# Clean up
redis = RedisClient.new(url: "redis://127.0.0.1:6379")
redis.call("DEL", "notifications")

puts "Starting subscriber in background thread..."
received_messages = []

subscriber = Client.new(url: "redis://127.0.0.1:6379")
thread = Thread.new do
  subscriber.subscribe("notifications") do |message|
    received_messages << message
    puts "✓ Received: #{message.inspect}"
    :stop if received_messages.size >= 3
  end
end

sleep 1

puts "\nPublishing 3 messages..."
publisher = Client.new(url: "redis://127.0.0.1:6379")

3.times do |i|
  message = {
    id: i + 1,
    type: "notification",
    message: "Test message #{i + 1}",
    timestamp: Time.now.to_i
  }
  publisher.publish("notifications", message)
  puts "→ Published: #{message[:message]}"
  sleep 0.5
end

puts "\nWaiting for messages to be received..."
sleep 2

thread.kill if thread.alive?

puts "\n#{'=' * 50}"
puts "Test Results:"
puts "=" * 50
puts "Messages published: 3"
puts "Messages received: #{received_messages.size}"
puts received_messages.size == 3 ? "✓ SUCCESS!" : "✗ FAILED"

# Clean up
redis.call("DEL", "notifications")
