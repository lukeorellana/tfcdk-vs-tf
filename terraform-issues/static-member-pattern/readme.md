# Static Member Pattern

This pattern is used to define a set of preconfigured configurations or objects that can be reused across different parts of the application. In Terraform HCL this requires a lot of complexity to create. A variable is used to contain the preconfigured settings in a map:

```hcl
variable "predefined_rules" {
  type        = any
  default     = []
  description = "Predefined rules"
}


variable "rules" {
  type = map(any)
  # [direction, access, protocol, source_port_range, destination_port_range, description]"
  # The following info are in the submodules: source_address_prefix, destination_address_prefix
  default = {
    #ActiveDirectory
    ActiveDirectory-AllowADReplication          = ["Inbound", "Allow", "*", "*", "389", "AllowADReplication"]
    ActiveDirectory-AllowADReplicationSSL       = ["Inbound", "Allow", "*", "*", "636", "AllowADReplicationSSL"]
    ActiveDirectory-AllowADGCReplication        = ["Inbound", "Allow", "Tcp", "*", "3268", "AllowADGCReplication"]
    ActiveDirectory-AllowADGCReplicationSSL     = ["Inbound", "Allow", "Tcp", "*", "3269", "AllowADGCReplicationSSL"]
    ActiveDirectory-AllowDNS                    = ["Inbound", "Allow", "*", "*", "53", "AllowDNS"]
    ActiveDirectory-AllowKerberosAuthentication = ["Inbound", "Allow", "*", "*", "88", "AllowKerberosAuthentication"]
    ActiveDirectory-AllowADReplicationTrust     = ["Inbound", "Allow", "*", "*", "445", "AllowADReplicationTrust"]
    ActiveDirectory-AllowSMTPReplication        = ["Inbound", "Allow", "Tcp", "*", "25", "AllowSMTPReplication"]
}
```
Users of the module can then feed in one of the `predefined_rules` to gain an abstracted configuration for NSG Rules:
```hcl
module "nsg" {
  source              = "../../"
  resource_group_name = var.resource_group_name
  use_for_each        = var.use_for_each

  security_group_name = var.security_group_name

  predefined_rules = [
    {
      name     = "SMTP"
      priority = 501
    },
  ]

  custom_rules               = var.custom_rules
  source_address_prefix      = var.source_address_prefix
  destination_address_prefix = var.destination_address_prefix
  tags                       = var.tags
}

```

The resource configruation takes the input and performs a series of lookups to feed in the correct values into the rule configuration:

```hcl


resource "azurerm_network_security_rule" "predefined_rules_for" {
  for_each = { for value in var.predefined_rules : value.name => value if var.use_for_each }

  access                                     = element(var.rules[lookup(each.value, "name")], 1)
  direction                                  = element(var.rules[lookup(each.value, "name")], 0)
  name                                       = lookup(each.value, "name")
  network_security_group_name                = azurerm_network_security_group.nsg.name
  priority                                   = each.value.priority
  protocol                                   = element(var.rules[lookup(each.value, "name")], 2)
  resource_group_name                        = data.azurerm_resource_group.nsg.name
  description                                = element(var.rules[lookup(each.value, "name")], 5)
  destination_address_prefix                 = lookup(each.value, "destination_application_security_group_ids", null) == null && var.destination_address_prefixes == null ? join(",", var.destination_address_prefix) : null
  destination_address_prefixes               = lookup(each.value, "destination_application_security_group_ids", null) == null ? var.destination_address_prefixes : null
  destination_application_security_group_ids = lookup(each.value, "destination_application_security_group_ids", null)
  destination_port_range                     = element(var.rules[lookup(each.value, "name")], 4)
  source_address_prefix                      = lookup(each.value, "source_application_security_group_ids", null) == null && var.source_address_prefixes == null ? join(",", var.source_address_prefix) : null
  source_address_prefixes                    = lookup(each.value, "source_application_security_group_ids", null) == null ? var.source_address_prefixes : null
  source_application_security_group_ids      = lookup(each.value, "source_application_security_group_ids", null)
  source_port_range                          = lookup(each.value, "source_port_range", "*") == "*" ? "*" : null
  source_port_ranges                         = lookup(each.value, "source_port_range", "*") == "*" ? null : [for r in split(",", each.value.source_port_range) : trimspace(r)]

  lifecycle {
    precondition {
      condition     = try(each.value.priority >= 100 && each.value.priority <= 4096, false)
      error_message = "Precondition failed: 'predefined_rules.priority' must be provided and configured between 100 and 4096 for predefined rules if 'var.use_for_each' is set to true."
    }
  }
}


```


## Terraform CDK Way

This pattern is much easier to apply in Terraform CDK. We use a class to define pre-defined rules:
```typescript
export class PreconfiguredRules {
  // SMTP
  static smtp: RuleConfig = {
    direction: "Inbound",
    access: "Allow",
    protocol: "Tcp",
    sourcePortRange: "*",
    destinationPortRange: "25",
    name: "SMTP",
    priority: 570,
    sourceAddressPrefix: "*",
    destinationAddressPrefix: "*",
  };
}
```
The class is imported when the user is configuring the NSG and dot notation can be used to select the desired pre-configured rule:
```typescript
import { PreconfiguredRules } from "../lib/preconfigured-rules";

const nsg = new network.SecurityGroup(this, "nsg", {
      name: `nsg-${this.name}`,
      location: "eastus",
      resourceGroup: resourceGroup,
      rules: [
        {
          name: "SSH",
          priority: 1001,
          direction: "Inbound",
          access: "Allow",
          protocol: "Tcp",
          sourcePortRange: "*",
          destinationPortRange: "22",
          sourceAddressPrefix: "10.23.15.38",
          destinationAddressPrefix: "VirtualNetwork",
        },
        PreconfiguredRules.smtp,
      ],
    });

```