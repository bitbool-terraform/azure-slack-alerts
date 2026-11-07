variable "resource_group" {
  type = string
}

variable "location" {
  type = string
}

variable "tags" {
  default = null
}

variable "project" {
  type        = string
  default = ""
}

variable "slack_channel" {
  type        = string
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