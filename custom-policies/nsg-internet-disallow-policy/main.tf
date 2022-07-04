
provider "azurerm" {
  features {}
}

resource "azurerm_policy_definition" "disallow_internet_definition" {
  name         = "disallowInternet"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Network - disallow internet hops"

  metadata = <<METADATA
     {
       "version": "1.0.0",
       "category": "Network"
     }
   METADATA

  policy_rule = <<POLICY_RULE
   {
       "if":{
          "anyOf":[
             {
                "allOf":[
                   {
                      "field":"type",
                      "equals":"Microsoft.Network/routeTables"
                   },
                   {
                      "count":{
                         "field":"Microsoft.Network/routeTables/routes[*]",
                         "where":{
                            "field":"Microsoft.Network/routeTables/routes[*].nextHopType",
                            "equals":"Internet"
                         }
                      },
                      "greater":0
                   }
                ]
             },
             {
                "allOf":[
                   {
                      "field":"type",
                      "equals":"Microsoft.Network/routeTables/routes"
                   },
                   {
                      "field":"Microsoft.Network/routeTables/routes/nextHopType",
                      "equals":"Internet"
                   }
                ]
             },
             {
                "allOf":[
                   {
                      "field":"type",
                      "equals":"Microsoft.Network/publicIPAddresses"
                   },
                   {
                      "field":"Microsoft.Network/publicIPAddresses/publicIPAllocationMethod",
                      "equals":"Static"
                   },
                   {
                      "field":"Microsoft.Network/publicIPAddresses/ipConfiguration",
                      "exists":false
                   }
                ]
             }
          ]
       },
       "then":{
          "effect": "[parameters('effect')]"
       }
    }
POLICY_RULE 

  parameters = <<PARAMETERS
     {
         "effect": {
                 "type": "String",
                 "metadata": {
                 "displayName": "Effect",
                 "description": "Enable or disable the execution of the policy"
                 },
                 "allowedValues": [
                 "AuditIfNotExists",
                 "Disabled",
                 "Deny"
                 ],
                 "defaultValue": "Deny"
             }
   }
 PARAMETERS

}

data "azurerm_subscription" "subscription_info" {

  name                = var.hub_firewall
  resource_group_name = azurerm_resource_group.rg.name

  
}

# using json file

resource "azurerm_policy_definition" "disallow_internet_definition1" {
  name                  = "disallow_internet_definition1"
  policy_type           = "Custom"
  mode                  = "All"
  display_name          = "Network - disallow internet hops"
  scope                = data.azurerm_subscription.subscription_info.id
  #management_group_name = var.definition_management_group
  policy_rule           = file("/Users/ankur/policy-deploy/custom-policies/nsg-internet-disallow-policy/azurepolicy.json")
  #parameters            = file("${path.module}/policies/resource-location/policy-parameters.json")
}

# using json file enbedded in code

resource "azurerm_policy_assignment" "disallow_internet_assignment" {
  name                 = "internet-policy-assignment"
  scope                = data.azurerm_subscription.subscription_info.id
  policy_definition_id = azurerm_policy_definition.disallow_internet_definition.id
  description          = "Deny route with next hop type internet and unattached static Public IPs to ensure no direct internet connection or route for any resoure."
  display_name         = "Network - disallow internet hops"

  parameters = var.disallow_internet_parameters

}

