variable "name" {
  type = string
}

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

variable "availability_zone_limit" {
  type = number
  default = 6
}

variable "ssh_cidrs" {
  type = list(string)
  default = []
}
