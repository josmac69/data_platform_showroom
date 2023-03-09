from kafka.admin import KafkaAdminClient, NewTopic
from kafka.errors import TopicAlreadyExistsError
#import kafka_utils

KAFKA_BOOTSTRAP_SERVERS = 'dpe-kafka.default.svc.cluster.local:9092'
KAFKA_TOPIC = 'data_ingestion'

# Define the Kafka broker configuration
bootstrap_servers = [KAFKA_BOOTSTRAP_SERVERS]

# Define the topic to check/create
topic_name = KAFKA_TOPIC

# Create an admin client to check/create topics
admin_client = KafkaAdminClient(bootstrap_servers=bootstrap_servers)

# Check if the topic exists
topic_exists = topic_name in admin_client.list_topics()

# Create the topic if it doesn't exist
if not topic_exists:
    topic = NewTopic(name=topic_name, num_partitions=1, replication_factor=1)
    try:
        admin_client.create_topics([topic])
    except TopicAlreadyExistsError:
        pass

# Close the admin client connection
admin_client.close()
