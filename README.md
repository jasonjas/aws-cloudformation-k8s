# aws-cloudformation-k8s
AWS Cloudformation template and bash scripts to run using aws cli to provision Kubernetes master and node.
This is for testing only

# Requirements
* aws cli
* aws secret access keys
* ec2 keypair named ec2-1 (can be changed in code)

# usage
## Create Servers
1. create and save files to ~/cloudformation directory
2. chmod 754 launch-kubernetes.sh
3. Run launch-kubernetes.sh
4. Enter name for the CloudFormation stack
5. once provisioned, IPs and information will be printed to screen

## Delete Server
1. chmod 754 delete-kubernetes.sh
2. ./delete-kubernets.sh
3. Enter name for the CloudFormation stack to delete - this will also delete the output files

