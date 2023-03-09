from kafka.admin import KafkaAdminClient, NewTopic
from kafka.errors import TopicAlreadyExistsError

def create_kafka_topic(topic_name, num_partitions=1, replication_factor=1, bootstrap_servers=['localhost:9092']):
    # Create an admin client to check/create topics
    admin_client = KafkaAdminClient(bootstrap_servers=bootstrap_servers)

    # Check if the topic exists
    topic_exists = topic_name in admin_client.list_topics()

    # Create the topic if it doesn't exist
    if not topic_exists:
        topic = NewTopic(name=topic_name, num_partitions=num_partitions, replication_factor=replication_factor)
        try:
            admin_client.create_topics([topic])
            print(f'Created Kafka topic "{topic_name}" with {num_partitions} partition(s) and {replication_factor} replication factor.')
        except TopicAlreadyExistsError:
            print(f'Kafka topic "{topic_name}" already exists.')
            pass

    # Close the admin client connection
    admin_client.close()

