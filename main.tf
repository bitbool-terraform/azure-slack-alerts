locals {
  slack_essentials  = "triggerBody()?['data']?['essentials']"
  slack_is_resolved = "equals(toLower(coalesce(${local.slack_essentials}?['monitorCondition'], 'Fired')), 'resolved')"
}

resource "azurerm_logic_app_workflow" "this" {
  name                = "${var.name_prefix}-ag-slack-app"
  resource_group_name = var.resource_group
  location            = var.location
  enabled             = true
  tags                = var.tags
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
  name         = "${var.name_prefix}-alert"
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
  name         = "${var.name_prefix}-slack"
  logic_app_id = azurerm_logic_app_workflow.this.id

  method = "POST"

  uri = "@parameters('slackWebhookUrl')"

  headers = {
    "Content-Type" = "application/json"
  }


  body = jsonencode({
    attachments = [
      {
        color = "@{if(${local.slack_is_resolved}, 'good', 'danger')}"

        fallback = "${var.name_prefix}-${var.designator}: @{coalesce(${local.slack_essentials}?['alertRule'], 'Azure Alert')}"

        mrkdwn_in = ["text"]

        text = join("\n", [
          "*@{if(${local.slack_is_resolved}, '🟢 RESOLVED', '🔴 FIRED')}* · *@{coalesce(${local.slack_essentials}?['alertRule'], 'Azure Alert')}*",

          "${var.name_prefix}-*${var.designator}* | `@{last(split(join(coalesce(${local.slack_essentials}?['alertTargetIDs'], createArray('unknown')), ', '), '/'))}`| @{coalesce(${local.slack_essentials}?['severity'], 'N/A')}",

          "@{coalesce(${local.slack_essentials}?['description'], 'No description provided')}"
        ])
      }
    ]
  })
}

resource "azurerm_monitor_action_group" "this" {
  name                = "${var.name_prefix}-slack-ag"
  resource_group_name = var.resource_group
  short_name          = substr("${var.name_prefix}",0,11)
  tags                = var.tags

  logic_app_receiver {
    name                    = "slack"
    resource_id             = azurerm_logic_app_workflow.this.id
    callback_url            = azurerm_logic_app_trigger_http_request.alert.callback_url
    use_common_alert_schema = true
  }
}