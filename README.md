# aws-cloudformation-k8s
AWS Cloudformation template and bash scripts to run using aws cli to provision Kubernetes master and node.
This is for testing only

note: This is currently only setup to work with a default VPC setup. It might fail if an additional VPC is created.

# Requirements
* aws cli
* aws secret access keys
* ec2 keypair

# Setup
1. chmod 754 manage-kubernetes.sh
2. Review / set the 3 main variables at the top of manage-kubernetes.sh
   * output_dir = the location where files will be stored locally, the location of this repository checkout
   * ssh_key = location of the ssh key used to log in to the servers
   * keypair = the key pair used for the EC2 servers


# usage
## Create Servers
1. Verify the variables at the top of manage-kubernetes.sh are correct
2. chmod 754 manage-kubernetes.sh
3. Run the command: ./manage-kubernetes.sh launch <stack-name>
4. Replace <stack-name> with the name for the CloudFormation stack
5. once provisioned, the IPs and ssh command to the master node will be printed to screen
6. An output file name <stack-name>-output.txt will be created in the $output_dir directory containing node information

## Delete Server
1. ./manage-kubernetes.sh delete <stack-name>
2. Replace <stack-name> with the name for the CloudFormation stack
3. This will delete the stack and the output file created

## get stacks
1. ./get-stacks.sh
2. Will print out all stacks that are not deleted

## get ssh command to master
1. ./manage-kubernetes.sh get-ssh <stack-name>
2. Will print the ssh command to the get to the master node of the stack (if output file exists)

## Connect node to existing stack
1. ./manage-kubernetes.sh connect-node <stack-name>
2. Will connect the node in <stack-name>-output.txt to the master node in same file
3. Useful when the initial 'launch' command fails due to a timeout
