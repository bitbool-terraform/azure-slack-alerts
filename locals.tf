locals {
  slack_essentials  = "triggerBody()?['data']?['essentials']"

  slack_is_resolved = "equals(toLower(coalesce(${local.slack_essentials}?['monitorCondition'], 'Fired')), 'resolved')"
  
  slack_metric = "triggerBody()?['data']?['alertContext']?['condition']?['allOf']?[0]"
  
  slack_value_line = "@{if(equals(${local.slack_essentials}?['signalType'], 'Metric'), concat('value = *', string(coalesce(${local.slack_metric}?['metricValue'], 'N/A')), '* (', coalesce(${local.slack_metric}?['operator'], '?'), ' ', string(coalesce(${local.slack_metric}?['threshold'], '?')), ')', decodeUriComponent('%0A')), '')}"

  #slack_alert_url = "@{if(empty(${local.slack_essentials}?['investigationLink']),concat('https://portal.azure.com/#blade/Microsoft_Azure_Monitoring/AlertDetailsTemplateBlade/alertId/',uriComponent(${local.slack_essentials}?['alertId'])),${local.slack_essentials}?['investigationLink'])}"

  slack_scoped_alert_id = "if(empty(${local.slack_essentials}?['alertTargetIDs']), ${local.slack_essentials}?['alertId'], concat(first(coalesce(${local.slack_essentials}?['alertTargetIDs'], createArray(''))), '/providers/Microsoft.AlertsManagement/alerts/', last(split(${local.slack_essentials}?['alertId'], '/'))))"

  slack_alert_url = "@{concat('https://portal.azure.com/#view/Microsoft_Azure_Monitoring_Alerts/AlertDetails.ReactView/alertId~/',uriComponent(${local.slack_scoped_alert_id}),'/invokedFrom/CopyLinkFeature')}"
}





  