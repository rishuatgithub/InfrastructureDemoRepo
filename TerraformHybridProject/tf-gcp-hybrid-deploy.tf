#####################################################################
### Terraform template for provisioning GCP instances in a VPC
### Author: Rishu Shrivastava
### Last Updated: 06-Jun-2020
#####################################################################

provider "google" {
  credentials = file("/Users/rishushrivastava/Documents/GCP/service-accounts/gcpproject-rks-32e77221ac22.json")
  project     = "gcpproject-rks"
  region      = "us-central1"
  zone        = "us-central1-a"
}

resource "google_compute_instance" "vm_instance" {
  name         = "myvminstance-1"
  machine_type = "f1-micro"
  zone        = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    #network       = google_compute_network.myhybrid_vpc_network.self_link
    network = "default"
    access_config {
    }
  }
}

#resource "google_compute_network" "myhybrid_vpc_network" {
#  name                    = "myhybrid-vpc-01"
#  auto_create_subnetworks = "true"
#}



output "vm_ip" {
 value = google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip
}
