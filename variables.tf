variable "resource_group" {
  type = string
}

variable "location" {
  type = string
}

variable "tags" {
  default = null
}

variable "slack_webhook_url" {
  type        = string
}

variable "name_prefix" {
  type = string
}
variable "designator" {
  type = string
}