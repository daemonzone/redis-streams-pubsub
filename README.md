# Redis Streams PubSub

A simple, elegant Ruby gem that provides a publish/subscribe API on top of Redis Streams. It simplifies working with Redis Streams by offering familiar pub/sub patterns with automatic consumer group management and message acknowledgment.

## Features

- **Simple API**: Familiar publish/subscribe interface
- **Consumer Groups**: Automatic consumer group creation and management
- **Message Acknowledgment**: Automatic XACK after message processing
- **JSON Support**: Automatic JSON serialization/deserialization
- **Blocking Reads**: Efficient blocking reads with configurable timeouts
- **Multiple Consumers**: Support for distributed message processing

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'redis-streams-pubsub'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install redis-streams-pubsub
```

## Requirements

- Ruby >= 3.0
- Redis >= 5.0 (for Redis Streams support)
- redis-client >= 0.26

## Quick Start

### Publishing Messages

```ruby
require 'redis-streams-pubsub'

# Option 1: Use a shorthand alias
Client = Redis::Streams::PubSub::Client

publisher = Client.new(url: "redis://localhost:6379")

# Publish a message
publisher.publish("notifications", {
  type: "user_signup",
  user_id: 123,
  email: "user@example.com"
})
```

### Subscribing to Messages

```ruby
require 'redis-streams-pubsub'

# Option 2: Include the module
include Redis::Streams::PubSub

subscriber = Client.new(url: "redis://localhost:6379")

# Subscribe and process messages
subscriber.subscribe("notifications") do |message|
  puts "Received: #{message}"
  # Process the message
  # Return :stop to exit the subscription loop
end
```

## Usage

### Shortening the Namespace

There are several ways to avoid typing the long namespace:

```ruby
# Option 1: Create an alias (recommended)
Client = Redis::Streams::PubSub::Client
client = Client.new

# Option 2: Include the module
include Redis::Streams::PubSub
client = Client.new

# Option 3: Assign to a local variable
PubSub = Redis::Streams::PubSub
client = PubSub::Client.new
```

### Basic Publisher

```ruby
Client = Redis::Streams::PubSub::Client

client = Client.new(url: "redis://localhost:6379")

# Publish messages to a topic
client.publish("events", { event: "page_view", page: "/home" })
client.publish("events", { event: "button_click", button: "signup" })
```

### Basic Subscriber

```ruby
include Redis::Streams::PubSub

client = Client.new(url: "redis://localhost:6379")

# Subscribe to a topic
client.subscribe("events") do |message|
  puts "Event: #{message['event']}"
  # Continue listening
end
```

### Stopping a Subscription

Return `:stop` from the block to exit the subscription loop:

```ruby
client.subscribe("events") do |message|
  puts "Received: #{message}"
  
  # Stop after processing a specific message
  :stop if message['type'] == 'shutdown'
end
```

### Custom Consumer Groups

By default, all subscribers use the same consumer group (`redis-streams-pubsub`), which means messages are distributed among subscribers (load balancing).

```ruby
# Subscribers in the same group share the workload
subscriber1.subscribe("events", group: "workers") { |msg| process(msg) }
subscriber2.subscribe("events", group: "workers") { |msg| process(msg) }

# Subscribers in different groups each receive all messages
subscriber3.subscribe("events", group: "analytics") { |msg| analyze(msg) }
subscriber4.subscribe("events", group: "logging") { |msg| log(msg) }
```

### Custom Consumer ID

Each subscriber gets a unique consumer ID by default. You can specify a custom one:

```ruby
client = Redis::Streams::PubSub::Client.new(
  url: "redis://localhost:6379",
  consumer: "worker-1"
)
```

### Error Handling

```ruby
begin
  client.subscribe("events") do |message|
    process_message(message)
  end
rescue Interrupt
  puts "Subscriber stopped"
rescue => e
  puts "Error: #{e.message}"
end
```

## How It Works

### Consumer Groups

The gem uses Redis Streams consumer groups to manage message distribution:

- Messages are added to a stream using `XADD`
- Consumer groups track which messages have been delivered
- Each consumer in a group receives different messages (load balancing)
- Messages are automatically acknowledged after processing

### Message Flow

1. **Publisher** calls `publish(topic, payload)`
   - Payload is serialized to JSON
   - Message is added to the Redis Stream

2. **Subscriber** calls `subscribe(topic)`
   - Consumer group is created (if it doesn't exist)
   - Subscriber blocks waiting for new messages
   - When a message arrives, the block is called
   - Message is automatically acknowledged

### Blocking Behavior

The subscriber uses `XREADGROUP` with a 5-second block timeout. This means:
- The subscriber waits up to 5 seconds for new messages
- If no messages arrive, it loops and waits again
- This is efficient and doesn't poll continuously

## Examples

See the [examples](examples/) directory for complete working examples:

- [publisher.rb](examples/publisher.rb) - Publishing messages
- [subscriber.rb](examples/subscriber.rb) - Subscribing to messages
- [README.md](examples/README.md) - Detailed examples documentation

To run the examples:

```bash
# Terminal 1: Start the subscriber
ruby examples/subscriber.rb

# Terminal 2: Run the publisher
ruby examples/publisher.rb
```

## API Reference

### `Redis::Streams::PubSub::Client`

#### `initialize(url: "redis://localhost:6379", consumer: nil)`

Creates a new client instance.

**Parameters:**
- `url` (String): Redis connection URL
- `consumer` (String, optional): Custom consumer ID (auto-generated if not provided)

#### `publish(topic, payload)`

Publishes a message to a topic.

**Parameters:**
- `topic` (String): The topic/stream name
- `payload` (Hash): Message payload (will be serialized to JSON)

**Returns:** Redis message ID

#### `subscribe(topic, group: DEFAULT_GROUP, &block)`

Subscribes to a topic and processes messages.

**Parameters:**
- `topic` (String): The topic/stream name
- `group` (String): Consumer group name (default: "redis-streams-pubsub")
- `block` (Block): Block to process each message

**Block Parameters:**
- `message` (Hash): Deserialized message payload

**Block Return:**
- Return `:stop` to exit the subscription loop
- Return anything else to continue listening

## Testing

Run the test suite:

```bash
bundle exec rspec
```

Run RuboCop:

```bash
bundle exec rubocop
```

## Development

After checking out the repo, run `bundle install` to install dependencies.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

This project is available as open source under the terms of the MIT License.

## Author

Davide V.
