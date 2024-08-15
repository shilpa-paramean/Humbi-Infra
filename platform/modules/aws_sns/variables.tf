variable "create" {
  description = "Whether to create SNS topic"
  type        = bool
  default     = true
}

variable "name" {
  description = "This is the human-readable name of the topic."
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
  default     = {}
}
