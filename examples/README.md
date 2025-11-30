# Redis Streams PubSub Examples

This directory contains examples demonstrating how to use the `redis-streams-pubsub` gem.

## Prerequisites

Make sure Redis is running on `localhost:6379`:

```bash
# Check if Redis is running
redis-cli ping
# Should return: PONG
```

## Running the Examples

### 1. Subscriber Example

Open a terminal and run the subscriber first:

```bash
ruby examples/subscriber.rb
```

The subscriber will start listening for messages on the `notifications` topic.

### 2. Publisher Example

Open another terminal and run the publisher:

```bash
ruby examples/publisher.rb
```

The publisher will send 5 messages to the `notifications` topic, one per second.

You should see the messages appearing in the subscriber terminal in real-time.

## How It Works

- **Publisher**: Creates messages and publishes them to a Redis Stream topic
- **Subscriber**: Listens to the topic using consumer groups and processes incoming messages
- **Consumer Groups**: Multiple subscribers can join the same group to distribute message processing
- **Acknowledgment**: Messages are automatically acknowledged after processing

## Stopping the Subscriber

Press `Ctrl+C` to gracefully stop the subscriber.

## Advanced Usage

### Multiple Subscribers

You can run multiple subscriber instances. They will all receive the same messages since each creates its own consumer within the group:

```bash
# Terminal 1
ruby examples/subscriber.rb

# Terminal 2
ruby examples/subscriber.rb
```

### Custom Consumer Groups

You can specify a custom consumer group to control message distribution:

```ruby
subscriber.subscribe(topic, group: "my-custom-group") do |message|
  # Process message
end
```

Subscribers in the same group will share the workload (each message goes to one subscriber), while subscribers in different groups will each receive all messages.
