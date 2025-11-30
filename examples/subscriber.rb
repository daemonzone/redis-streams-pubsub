#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "redis-streams-pubsub"

# Create a subscriber client
subscriber = Redis::Streams::PubSub::Client.new(url: "redis://127.0.0.1:6379")

# Topic to subscribe to
topic = "notifications"

puts "Subscribing to '#{topic}' topic..."
puts "Waiting for messages (press Ctrl+C to stop)...\n\n"

# Subscribe and process messages
begin
  subscriber.subscribe(topic) do |message|
    puts "Received: #{message.inspect}"
    puts "  - ID: #{message['id']}"
    puts "  - Type: #{message['type']}"
    puts "  - Message: #{message['message']}"
    puts "  - Timestamp: #{Time.at(message['timestamp'])}"
    puts ""
    
    # Continue listening (don't return :stop)
    nil
  end
rescue Interrupt
  puts "\nSubscriber stopped."
end
