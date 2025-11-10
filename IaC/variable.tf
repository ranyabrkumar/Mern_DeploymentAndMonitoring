variable "key_name" {
    type = string
    default = "Severless_rbrk" 
}

variable "aws_region" {
  type    = string
  default = "us-west-2"
}
variable "aws_accesskey" {
  type      = string
  sensitive = true
}
variable "aws_secretkey" {
  type      = string
  sensitive = true
}
variable "project_name" {
  type    = string
  default = "Montoring-Project"
}