##### Creating PubSub Topics and Subscription in GCP #######
##### author: rishu shrivastava

project = "GCPProject-RKS"
region = "us-central1"
credentials_loc = "/Users/rishushrivastava/Documents/GCP/service-accounts/gcpproject-rks-0b39f2861c13.json"

pubsub_topic_name="avro-demo-test-topic"
pubsub_topic_sub_name="avro-demo-test-topic-sub"

pubsub_ack_deadline="20"
retain_ack_message=true
message_retention_duration="1200s"
ttl="300000.5s"


