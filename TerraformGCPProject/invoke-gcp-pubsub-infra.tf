variable "credentials_loc" {}
variable "project" {}
variable "region" {}
variable "pubsub_topic_name" {}
variable "pubsub_topic_sub_name" {}
variable "pubsub_ack_deadline" {}
variable "retain_ack_message" {}
variable "message_retention_duration" {}
variable "ttl" {}


provider "google" {
  credentials = file(var.credentials_loc)
  project     = var.project
  region      = var.region
}


resource "google_pubsub_topic" "gcp_pubsub_topic" {
  project= var.project
  name = var.pubsub_topic_name
  labels = {
    name = var.pubsub_topic_name
  }
}

resource "google_pubsub_subscription" "gcp_pubsub_sub" {
  project = var.project
  name  = var.pubsub_topic_sub_name
  topic = google_pubsub_topic.gcp_pubsub_topic.name

  message_retention_duration = var.message_retention_duration
  retain_acked_messages      = var.retain_ack_message
  ack_deadline_seconds       = var.pubsub_ack_deadline

  labels = {
    name = var.pubsub_topic_sub_name
  }

  expiration_policy {
    ttl = var.ttl
  }
  
}


