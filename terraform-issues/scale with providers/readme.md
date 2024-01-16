# Count or ForEach with providers

It is useful to add platform specific helm charts to AKS modules so all teams can have a defined setup. However this can not be easily scaled if using the same Terraform State is desired:
```hcl
module "aks_cluster_with_nginx" {
  source = "./module"

  for_each = toset(["cluster1", "cluster2", "cluster3"])
  resource_group_name = "rg-${each.key}"
  location            = "East US"  # Replace with the desired location
  cluster_name        = "aks-${each.key}"
  dns_prefix          = "dns-${each.key}"
  node_count          = 1
}
```
This causes issues at scale because count and for_each cannot be used on a provider:
```hcl
Initializing the backend...
Initializing modules...
- aks_cluster in module
╷
│ Error: Module is incompatible with count, for_each, and depends_on
│ 
│   on main.tf line 19, in module "aks_cluster":
│   19:   for_each = toset(["cluster1", "cluster2", "cluster3"])
│ 
│ The module at module.aks_cluster is a legacy module which contains its own local provider configurations, and so calls to it may not use the count, for_each, or depends_on arguments.
│ 
│ If you also control the module "./module", consider updating this module to instead expect provider configurations to be passed by its caller.

```

## The Terraform CDK Way

Terraform CDK can be configured to not use for_each or count to create loops within Terraform, this logic is handled within the programming language itself and the proper Terraform configuration is generated once converted:
```typescript
import { Construct } from 'constructs';
import { App, TerraformStack } from 'cdktf';
import { AzurermProvider, KubernetesCluster, ResourceGroup } from '@cdktf/provider-azurerm';
import { HelmProvider, Release } from '@cdktf/provider-helm';

class MyAksStack extends TerraformStack {
  constructor(scope: Construct, name: string) {
    super(scope, name);

    new AzurermProvider(this, 'AzureRm', {
      features: {}
    });

    const clusterNames = ["cluster1", "cluster2", "cluster3"]; // Define your cluster names here

    clusterNames.forEach((clusterName, index) => {
      const resourceGroup = new ResourceGroup(this, `ResourceGroup${index}`, {
        name: `${clusterName}-rg`,
        location: 'East US',
      });

      const aksCluster = new KubernetesCluster(this, `AKSCluster${index}`, {
        name: clusterName,
        location: resourceGroup.location,
        resourceGroupName: resourceGroup.name,
        dnsPrefix: `${clusterName}-dns`,
        defaultNodePool: {
          name: 'default',
          nodeCount: 1,
          vmSize: 'Standard_DS2_v2',
        },
        identity: {
          type: 'SystemAssigned',
        },
      });

      new HelmProvider(this, `Helm${index}`, {});

      new Release(this, `nginxRelease${index}`, {
        name: `nginx-${clusterName}`,
        chart: 'nginx-stable',
        repository: 'https://helm.nginx.com/stable',
        version: '0.7.0', // Use the appropriate version
      });
    });
  }
}

const app = new App();
new MyAksStack(app, 'cdktf-aks-example');
app.synth();

```