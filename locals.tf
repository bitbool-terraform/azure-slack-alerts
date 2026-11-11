locals {
  slack_essentials  = "triggerBody()?['data']?['essentials']"

  slack_is_resolved = "equals(toLower(coalesce(${local.slack_essentials}?['monitorCondition'], 'Fired')), 'resolved')"
  
  slack_metric = "triggerBody()?['data']?['alertContext']?['condition']?['allOf']?[0]"
  
  slack_value_line = "@{if(equals(${local.slack_essentials}?['signalType'], 'Metric'), concat('value = *', string(coalesce(${local.slack_metric}?['metricValue'], 'N/A')), '* (', coalesce(${local.slack_metric}?['operator'], '?'), ' ', string(coalesce(${local.slack_metric}?['threshold'], '?')), ')', decodeUriComponent('%0A')), '')}"

  slack_alert_url = "@{if(empty(${local.slack_essentials}?['investigationLink']),concat('https://portal.azure.com/#blade/Microsoft_Azure_Monitoring/AlertDetailsTemplateBlade/alertId/',uriComponent(${local.slack_essentials}?['alertId'])),${local.slack_essentials}?['investigationLink'])}"
}
