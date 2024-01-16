variable "tags_to_ignore" {
  type        = list(string)
  description = "Tags to ignore"
}

variable "name" {
  type        = string
  description = "resource group name"
}

variable "location" {
  type        = string
  description = "location to deploy resource"
}
