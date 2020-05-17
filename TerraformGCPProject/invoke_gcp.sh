
terraform init

terraform plan -var-file="invoke-gcp-pubsub-infra-var.tfvars" --out "gcp_pubsub_plan.out"

terraform apply "gcp_pubsub_plan.out"

terraform apply -var-file="invoke-gcp-pubsub-infra-var.tfvars"  -lock=false

terraform destroy -var-file="invoke-gcp-pubsub-infra-var.tfvars" -lock=false