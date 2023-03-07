import protobuf
import protobuf_to_dict
import person_pb2
from google.protobuf import message

person = person_pb2.Person()
person.id = 123
person.name = 'John Doe'
person.email = 'jdoe@example.com'

# Serialize the message to a binary string
data = person.SerializeToString()

# Deserialize the message from the binary string
person2 = person_pb2.Person()
person2.ParseFromString(data)

# Convert the message to a dictionary
person_dict = protobuf_to_dict.protobuf_to_dict(person2)

# Print the dictionary
print(person_dict)
