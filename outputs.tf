output "logic_app_id" {
  value = azurerm_logic_app_workflow.this.id
}

output "callback_url" {
  value     = azurerm_logic_app_trigger_http_request.alert.callback_url
  sensitive = true
}

output "action_group_id" {
  value = azurerm_monitor_action_group.this.id
}