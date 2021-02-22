
### terraform backend - consul
terraform {
  backend "consul"{
      address = "demo.consul.io"
      path = "terraform/myproject"
  }
}

### terraform backend - s3
### remember to use aws configure because 
terraform {
  backend "s3"{
    bucket = "my-backend-bucket"
    key = "terraform/myproject"
    region = "eu-central-1"
  }
}