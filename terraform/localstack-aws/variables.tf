variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
  default     = "change_me_in_tfvars"
}
