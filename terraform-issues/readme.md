# Terraform issues with dynamic lifecycle block
Currently lifecycle blocks do not take variables. This prevents the lifecycle block from being dynamically modified. This creates issues with day 2 administration, it is not uncommon for random tags to be applied to different environments in order to integrate other forms of automation or processes. This creates additional drift in environments where it would be much easier to update a dynamic list of ignored tags:

```hcl
 Error: Invalid expression
│ 
│   on module/rg.tf line 11, in resource "azurerm_resource_group" "rg":
│   11:       ignore_changes = var.tags_to_ignore
│ 
│ A static list expression is required.
```


## The Terraform CDK Way

The Terraform CDK enables the use of an "escape hatch," which is a powerful feature allowing for more flexible and granular customization of resources. This is particularly beneficial when using constructs that might not expose all underlying resource properties directly. The escape hatch mechanism permits additional configurations that aren't natively supported by the high-level construct interface.

In the provided TypeScript code, the Terraform CDK is used to create an Azure Resource Group with the ResourceGroup construct. The addOverride method serves as the escape hatch in this case. It is utilized to manually insert a lifecycle configuration that includes an ignore_changes array. This array can be populated with properties that should be ignored during subsequent Terraform updates, preventing unintended or disruptive changes.

For example, in your code snippet, the ignore_changes array can be customized based on the props.ignoreChanges property, allowing for dynamic modification of the resource's behavior. This flexibility is a significant advantage of the Terraform CDK, as it enables users to tailor resource management to specific requirements that might not be directly supported by the predefined constructs, thus bridging the gap between high-level abstraction and low-level control.

```typescript

 const azurermResourceGroupRg = new ResourceGroup(this, "rg", {
      ...defaults,
      tags: props.tags,
    });

    azurermResourceGroupRg.addOverride("lifecycle", [
      {
        ignore_changes: props.ignoreChanges || [],
      },
    ]);

```
Example:
```typescript
new rg.Group(this, "testRG", {
    name: `rg-${this.name}`,
    location: "eastus",
    tags: {
    name: "test",
    Env: "NonProd",
    },
    ignoreChanges: ['tags["Environment"]', 'tags["SkipSecurity"]'],
});
```

Generated Terraform:
```json
 "lifecycle": [
          {
            "ignore_changes": [
              "tags[\"Environment\"]",
              "tags[\"SkipSecurity\"]"
            ]
          }
        ],
```