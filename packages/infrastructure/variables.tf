variable "cidr" {
  type = string
}

variable "aws_region" {
  type = string
  default = "us-east-1"
}

variable "aws_azs" {
  type = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

/*
 * Certain aws resources like RDS clusters have a minimum
 * number of AZs even if instances within that AZ are not created.
 * This caps the AZs to less than this number during development to
 * save on costs during development.
 */
variable "limit_azs" {
  type = number
  default = 6
}

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
