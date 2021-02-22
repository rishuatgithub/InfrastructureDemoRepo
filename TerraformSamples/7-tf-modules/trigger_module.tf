module "my-module" {
    source = "./my-module"
    region = "us-west-1"
    ip-range = "10.0.0.0/8"
    cluster-size = 3
}