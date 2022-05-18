variable "cidr" {
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

variable "availability_zones" {
  type = list(string)
}
