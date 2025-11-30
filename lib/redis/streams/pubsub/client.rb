# frozen_string_literal: true

require "redis-client"
require "json"
require "securerandom"

module Redis
  module Streams
    module PubSub
      # Client for publishing and subscribing to Redis Streams
      class Client
        DEFAULT_GROUP = "redis-streams-pubsub"

        def initialize(url: "redis://localhost:6379", consumer: nil)
          @url = url
          @redis = RedisClient.new(url: url, timeout: 10.0)
          @consumer = consumer || "consumer-#{SecureRandom.hex(3)}"
        end

        def publish(topic, payload)
          # Use a separate connection for publishing to avoid conflicts with blocking reads
          redis = RedisClient.new(url: @url)
          redis.call("XADD", topic, "*", "data", payload.to_json)
        ensure
          redis&.close
        end

        def subscribe(topic, group: DEFAULT_GROUP, &block)
          create_group(topic, group)

          catch(:stop_subscription) do
            loop { process_stream_entries(topic, group, &block) }
          end
        end

        private

        def process_stream_entries(topic, group, &)
          entries = read_stream_entries(topic, group)
          return unless entries && !entries.empty?

          _, messages = entries.first
          process_messages(topic, group, messages, &)
        end

        def read_stream_entries(topic, group)
          @redis.call(
            "XREADGROUP",
            "GROUP", group, @consumer,
            "BLOCK", 5000,
            "STREAMS", topic, ">"
          )
        end

        def process_messages(topic, group, messages)
          messages.each do |id, fields|
            data = parse_message_data(fields[1])
            result = yield(data)
            @redis.call("XACK", topic, group, id)

            throw(:stop_subscription) if result == :stop
          end
        end

        def parse_message_data(raw_data)
          JSON.parse(raw_data)
        rescue StandardError
          raw_data
        end

        def create_group(topic, group)
          @redis.call("XGROUP", "CREATE", topic, group, "$", "MKSTREAM")
        rescue RedisClient::CommandError => e
          raise unless e.message.include?("BUSYGROUP")
        end
      end
    end
  end
end
