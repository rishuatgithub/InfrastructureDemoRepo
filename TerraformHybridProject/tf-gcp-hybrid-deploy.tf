
provider "google" {
  credentials = file("/Users/rishushrivastava/Documents/GCP/service-accounts/gcpproject-rks-0b39f2861c13.json")
  project     = "GCPProject-RKS"
  region      = "us-central1"
  zone        = "us-central1-c"
}

resource "google_compute_instance" "rks_hybrid_gcp_vm" {
  name = "rks_hybrid_gcp_vm"
  machine_type = "f1.micro"
  
  zone = "us-central1-c"

  boot_disk {
   initialize_params {
        image = "debian-cloud/debian-9"
    }
  }

 network_interface {
   network = "default"
   access_config {
    }
 }

 metadata_startup_script = "sudo apt-get update"

}

