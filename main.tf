locals {
  project = coalesce(var.project, var.name_prefix)
}

resource "azurerm_logic_app_workflow" "this" {
  name                = "${var.name_prefix}-ag-slack-app"
  resource_group_name = var.resource_group
  location            = var.location
  enabled             = true

  workflow_parameters = {
    slackWebhookUrl = jsonencode({
      type = "SecureString"
    })
  }

  parameters = {
    slackWebhookUrl = var.slack_webhook_url
  }
}

resource "azurerm_logic_app_trigger_http_request" "alert" {
  name         = "azure-monitor-alert"
  logic_app_id = azurerm_logic_app_workflow.this.id
  method       = "POST"

  schema = jsonencode({
    type = "object"
    properties = {
      schemaId = {
        type = "string"
      }
      data = {
        type = "object"
        properties = {
          essentials = {
            type = "object"
          }
        }
      }
    }
  })
}

resource "azurerm_logic_app_action_http" "slack" {
  name         = "send-to-slack"
  logic_app_id = azurerm_logic_app_workflow.this.id

  method = "POST"

  uri = "@parameters('slackWebhookUrl')"

  headers = {
    "Content-Type" = "application/json"
  }

  body = jsonencode({
    text = join("\n", [
      "*Azure Monitor | ${local.project} | ${var.designator}*",
      "_Channel: ${var.slack_channel}_",
      "",
      "@{if(equals(toLower(coalesce(triggerBody()?['data']?['essentials']?['monitorCondition'], 'Fired')), 'resolved'), ':white_check_mark: *RESOLVED*', ':rotating_light: *FIRED*')}",
      "",
      "*Alert:* @{coalesce(triggerBody()?['data']?['essentials']?['alertRule'], 'Azure Monitor notification')}",
      "*Severity:* @{coalesce(triggerBody()?['data']?['essentials']?['severity'], 'N/A')}",
      "*Signal:* @{coalesce(triggerBody()?['data']?['essentials']?['signalType'], 'N/A')}",
      "*Resources:* @{join(coalesce(triggerBody()?['data']?['essentials']?['alertTargetIDs'], json('[]')), ', ')}",
      "*Description:* @{coalesce(triggerBody()?['data']?['essentials']?['description'], 'No description provided')}",
      "*Time:* @{coalesce(triggerBody()?['data']?['essentials']?['resolvedDateTime'], triggerBody()?['data']?['essentials']?['firedDateTime'], 'N/A')}"
    ])
  })
}

resource "azurerm_monitor_action_group" "this" {
  name                = "${var.name_prefix}-slack-ag"
  resource_group_name = var.resource_group
  short_name          = substr("${var.name_prefix}",-7,-1)
  logic_app_receiver {
    name                    = "slack"
    resource_id             = azurerm_logic_app_workflow.this.id
    callback_url            = azurerm_logic_app_trigger_http_request.alert.callback_url
    use_common_alert_schema = true
  }
}