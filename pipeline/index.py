import json
import os
from google.cloud import pubsub_v1
import random
import time
import string
import math


provinces = ['Alberta',
            'British Columbia',
            'Manitoba',
            'New Brunswick',
            'Newfoundland and Labrador',
            'Northwest Territories',
            'Nova Scotia',
            'Nunavut',
            'Ontario',
            'Prince Edward Island',
            'Quebec',
            'Saskatchewan',
            'Yukon']

# create complete fake address
def address_generator(province):
    street_addr_first_part = ''.join(["{}".format(random.randint(0, 9)) for num in range(0, 4)])
    street_addr_second_part = ''.join(random.sample(string.ascii_lowercase[0::], k = math.floor(random.randint(5, 15))))
    selected_province = random.sample(province, k = 1)
    complete_address = ''.join(street_addr_first_part) + " " + str(street_addr_second_part)+ " " + str(selected_province[0])
    return complete_address

# create random data points
def rand_data_generator():
    first_name = ''.join(random.sample(string.ascii_lowercase[0::], k = math.floor(random.randint(5, 10))))
    last_name = ''.join(random.sample(string.ascii_lowercase[0::], k = math.floor(random.randint(5, 10))))
    gender = random.sample(["male", "female"], k = 1)
    age = random.randint(18, 70)
    address = address_generator(provinces)

    schema = {
        "type": "record",
        "name": "User",
        "fields": [
            {"name": "first_name", "type": "string"},
            {"name": "last_name", "type": "string"},
            {"name": "gender", "type": "string"},
            {"name": "age", "type": "int"},
            {"name": "address", "type": "string"}
        ]
    }

    data = create_user_data(first_name, last_name, gender[0], age, address)

    # Get Avro-encoded data
    final_data = format_data(data)
    publish_to_pubsub(os.getenv('GOOGLE_CLOUD_PROJECT'), 'user-data', final_data)

# Function to create the data dictionary
def create_user_data(first_name, last_name, gender, age, address):
    return {
        "first_name": first_name,
        "last_name": last_name,
        "gender": gender[0],
        "age": age,
        "address": address
    }

# covert to json format
def format_data(data):
    row = json.dumps(data).encode('utf-8')
    return  row


# Publish to Pub/Sub
def publish_to_pubsub(project_id, topic_name, avro_data):
    publisher = pubsub_v1.PublisherClient()
    topic_path = publisher.topic_path(project_id, topic_name)

    # Publish the Avro-encoded message
    future = publisher.publish(topic_path, avro_data)
    print(f"Published message ID: {future.result()}")

x = 100
while x > 0:
    rand_data_generator()
    x -= 1
    time.sleep(15)
