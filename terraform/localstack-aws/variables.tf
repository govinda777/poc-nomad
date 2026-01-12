variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
}

variable "aws_access_key" {
  description = "AWS Access Key"
  type        = string
  default     = "test"
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
  type        = string
  default     = "test"
}
