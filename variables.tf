variable "resource_group" {
  type = string
}

variable "location" {
  type = string
}

variable "project" {
  type        = string
}

variable "slack_channel" {
  type        = string
}

variable "slack_webhook_url" {
  type        = string
}

variable "name_prefix" {
  type = string
  default = "slack-ag"
}