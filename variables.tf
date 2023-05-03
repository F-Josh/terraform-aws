variable "env_code" {
  description = "The name of the environment"
  type        = string
  default     = "Dev"
}

variable "instance_name" {
  description = "The name of the instance"
  type        = list(string)
  default     = ["public", "private"]
}