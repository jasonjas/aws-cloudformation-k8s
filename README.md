# aws-cloudformation-k8s
AWS Cloudformation template and bash scripts to run using aws cli to provision Kubernetes master and node.

# Requirements
* aws cli
* aws secret access keys
* ec2 keypair named ec2-1 (can be changed in code)

# usage
1. create and save files to ~/cloudformation directory
2. chmod 754 launch-kubernetes.sh
3. Run launch-kubernetes.sh
4. Enter name for the CloudFormation stack
5. once provisioned, IPs and information will be printed to screen

