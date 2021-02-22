variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
variable "AWS_REGION" {
  default="us-east-1"
}
variable "AMIS" {
  type="map"
  default = {
      us-east-1="ami-03d6586e30037dd42"
      us-west-1="ami-0e30995d79cf0caac"
      eu-west-1="ami-00801a692d6c8a45d"
  }
}