variable "elasticapp" {
  default = "dos13-aderekh-app"
}
variable "beanstalkappenv" {
  default = "dos13-aderekh-env"
}
variable "solution_stack_name" {
  type = string
}
variable "tier" {
  type = string
}
 
variable "vpc_id" {}
variable "public_subnets" {}
variable "elb_public_subnets" {}