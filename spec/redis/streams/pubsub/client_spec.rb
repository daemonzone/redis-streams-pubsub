require "spec_helper"
require "redis/streams/pubsub/client"

RSpec.describe Redis::Streams::PubSub::Client do
  let(:bus) { described_class.new(url: "redis://127.0.0.1:6379") }
  let(:topic) { "rspec_test_topic" }

  after do
    # Clean up the stream after each test
    redis = RedisClient.new(url: "redis://127.0.0.1:6379")
    redis.call("DEL", topic)
  end

  it "publishes and consumes a message" do
    received = nil
    subscriber = described_class.new(url: "redis://127.0.0.1:6379")
    publisher = described_class.new(url: "redis://127.0.0.1:6379")

    thread = Thread.new do
      subscriber.subscribe(topic) do |msg|
        received = msg
        :stop
      end
    end

    # Give the subscriber time to start
    sleep 0.5

    # Publish message after subscription is active
    publisher.publish(topic, { foo: "bar" })

    # Wait up to 2 seconds for message to arrive
    Timeout.timeout(2) do
      sleep 0.1 until received
    end

    expect(received).to eq({ "foo" => "bar" })

    thread.kill
  end

end
