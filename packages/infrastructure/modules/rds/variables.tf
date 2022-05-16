variable "name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "up" {
  type = bool
  default = false
}

variable "vpc_id" {
    type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "ingress_sgs" {
  type = list(string)
}

variable "egress_sgs" {
  type = list(string)
}
