variable "name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "up" {
  type = bool
  default = true
}

variable "home_ips" {
  type = list(string)
  default = []
}
