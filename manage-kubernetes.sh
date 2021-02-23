#!/bin/bash

output_dir=~/cloudformation
ssh_key=~/.ssh/aws-rsa
keypair=ec2-1

note () {
        echo accepts only 1 or 2 parameters
        echo '$0 [launch | delete | connect-node | get-ssh] stack-name'
        echo '$0 [launch | delete | connect-node | get-ssh]'
}

get_ssh() {
	output_file=$output_dir/$stackname-output.json
	masterip=$(cat $output_file | jq -r '.[] | select(.OutputKey=="AdmPublicIP") | .OutputValue')
	echo ssh -i $ssh_key ec2-user@$masterip
}

connect_node() {
	output_file=$output_dir/$stackname-output.json
	aws cloudformation describe-stacks --stack-name $stackname | jq '.["Stacks"][]["Outputs"]' | tee $output_file
	masterip=$(cat $output_file | jq -r '.[] | select(.OutputKey=="AdmPublicIP") | .OutputValue')
	nodeip=$(cat $output_file | jq -r '.[] | select(.OutputKey=="NodePublicIP") | .OutputValue')
	echo master ip = $masterip
	echo node ip = $nodeip
	sleep 2
	echo wait for cluster to create and then connect node
	scp -i $ssh_key -o "StrictHostKeyChecking=no" $output_dir/userdata-check.sh ec2-user@$masterip:/tmp/userdata-check.sh > /dev/null
	command=$(ssh -i $ssh_key -o "StrictHostKeyChecking=no" ec2-user@$masterip "chmod 754 /tmp/userdata-check.sh; /tmp/userdata-check.sh")
	if [ $? == 0 ]
	then
		ssh -i $ssh_key -o "StrictHostKeyChecking=no" ec2-user@$nodeip "$command"
	else
		echo error with user-data file: $command
	fi
}

launch () { 
        template_file=$output_dir/kubernetes-nodes.yaml
        aws cloudformation deploy --template-file $template_file --stack-name $stackname --parameter-overrides ParameterKey=KeyNameParam,ParameterValue=$keypair
        if [ $? == 0 ]
        then 
		connect_node
        else
                echo $stackname returned code $?
        fi
        echo ssh -i $ssh_key ec2-user@$masterip
}

delete() {
	echo removing stack $stackname
        aws cloudformation delete-stack --stack-name $stackname
        if [ $? == 0 ]
        then
                rm $output_dir/$stackname-output.json
                fi
}

mkdir -p $output_dir

if [ $# -eq 0 ]
then 
	note
	exit 1
fi

if [ $1 == "launch" ] || [ $1 == "delete" ] || [ $1 == "connect-node" ] || [ $1 == "get-ssh" ]
then
	action=$1
	if [ $action == "connect-node" ]
	then 
		action=connect_node
	elif [ $action == "get-ssh" ]
	then
		action=get_ssh
	fi
        if [ $# -eq 1 ]
        then 
                read -p "what is the stack name? " stackname
                $action $stackname
        elif [ $# -eq 2 ]
        then
                stackname=$2
                $action $stackname
        else
                note
        fi
else
        note
fi
