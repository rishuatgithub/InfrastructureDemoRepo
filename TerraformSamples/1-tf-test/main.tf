variable "myvar" {
  type = "string"
  default = "Hello Terraform"  ## printing variables: "${var.myvar}"; var.myvar
}

variable "mymap" {
  type = map(string)
  default = {
      mykey = "my map key"  ## printing map variables: var.mymap["mykey"]   
  }
}

variable "mylist" {
  type = list
  default = [1,2,3]
}

### variable types in tf.
### Simple Type: string, number, bool
### Complex Type: list(type), map(type), set(type), object({<attr_name>=<type>,...}), tuple([<type>,...])
###                 -> object is a like map with many datatypes