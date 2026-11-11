| Version    | Changes |
| -------- | ------- |
| v1.1.0  | First stable.   |
| v1.2.0  | Added clickable alert.   |

```hcl
module "azure-slack-alerts" {
  source = "../../bitbool-terraform/azure-slack-alerts"

  name_prefix    = 
  designator     = 

  resource_group = var.resource_group
  location       = var.location

  slack_webhook_url = data.azurerm_key_vault_secret.slack_webhook.value
}
```