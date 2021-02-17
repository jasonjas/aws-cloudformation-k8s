# aws-cloudformation-k8s
AWS Cloudformation template and bash scripts to run using aws cli to provision Kubernetes master and node.
This is for testing only

note: This is currently only setup to work with a default VPC setup. It might fail if an additional VPC is created.

# Requirements
* aws cli
* aws secret access keys
* ec2 keypair named ec2-1 (can be changed in kubernetes-nodes.yaml)

# usage
## Create Servers
1. create and save files to ~/cloudformation directory
2. chmod 754 manage-kubernetes.sh
3. Run the command: ./manage-kubernetes.sh launch <stack-name>
4. Replace <stack-name> with the name for the CloudFormation stack
5. once provisioned, the IPs and ssh command to the master node will be printed to screen
6. An output file name <stack-name>-output.txt will be created in the ~/cloudformation/ directory containing node information

## Delete Server
1. ./manage-kubernetes.sh delete <stack-name>
2. Replace <stack-name> with the name for the CloudFormation stack
3. This will delete the stack and the output file created

