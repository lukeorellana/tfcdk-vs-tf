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

The escape hatch is a way to directly influence the underlying Terraform resources when the high-level constructs in the CDK don't expose certain properties or behaviors you need to modify.

In the example, using addOverride in the CDK is like manually adjusting the HCL in regular Terraform. It lets you fine-tune the behavior of resources (like lifecycle settings) beyond what the standard Terraform HCL can offer. This is especially useful when you want to maintain certain aspects of your infrastructure in a specific state, even as other parts change such as ignoring tags.

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