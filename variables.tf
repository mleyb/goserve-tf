variable "aws_access_key" {
  description = "AWS Access Key"
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
}

variable "aws_region" {
  default     = "eu-west-1"
  description = "AWS Region"
}

variable "instance_type" {
  default     = "t2.micro"
  description = "Instance type"
}