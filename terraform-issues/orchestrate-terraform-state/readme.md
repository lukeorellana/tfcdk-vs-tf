# orchestrate terraform state
Splitting up Terraform state and using an orchestration tool for managing multiple states is essential for several reasons:

Scalability: As infrastructure grows, managing everything in a single state file becomes impractical and risky. Splitting state allows for managing different parts of the infrastructure independently, making it more scalable and easier to handle.

Performance: Large state files can slow down Terraform operations. Smaller, segmented states improve performance by reducing the amount of data Terraform needs to process for each operation.

Reduced Blast Radius: Splitting state limits the impact of mistakes. With a monolithic state, an error can potentially affect the entire infrastructure. Segmented states confine the impact to a smaller portion, enhancing overall safety.

Team Collaboration: In a team environment, working on the same state file can lead to conflicts and overwrites. Splitting the state allows different teams or team members to work on different aspects of the infrastructure without interfering with each other.

Parallel Execution: Segmented states allow for parallel execution of Terraform commands, which can significantly speed up development and deployment processes.

Security: By splitting state files, you can apply different access controls to different parts of your infrastructure. This is particularly important for sensitive data or critical infrastructure components.

State Locking Issues: With a single state file, only one person or process can modify the infrastructure at a time (due to state locking). Multiple state files allow for more concurrent changes.

Easier State Management and Recovery: In case of state corruption or the need for state recovery, it's easier and safer to deal with smaller, specific state files than a single large one.

Terraform requires the use of an orchestration tool like Terragrunt, Atmos, or home made script. This means another tool that developers need to learn and use.


## Terraform CDK Multiple Stacks

Creating and using multiple stacks in Terraform with the Cloud Development Kit (CDK) allows for better organization and management of your infrastructure as code. Each stack can represent a logical group of resources, such as networking, compute, or database resources, and can be deployed independently.


```typescript
import { App } from 'cdktf';
import { NetworkStack } from './network-stack';
import { ComputeStack } from './compute-stack';

const app = new App();

const networkStack = new NetworkStack(app, 'network-stack');
new ComputeStack(app, 'compute-stack', {
  vpcId: networkStack.vpcId.stringValue,
  subnetId: networkStack.subnetId.stringValue
});

app.synth();


```