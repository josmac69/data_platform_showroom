import protobuf.example_pb2 as example_pb2

# Define a new example protobuf message
example = example_pb2.Example()
example.id = 1
example.name = 'Example'
example.value = 42

# Serialize the message to bytes
message_bytes = example.SerializeToString()

# Print the serialized message
print(message_bytes)
