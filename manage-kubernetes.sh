#!/bin/bash

output_dir=~/cloudformation
ssh_key=~/.ssh/aws-rsa
keypair=ec2-1

note () {
        echo accepts only 1 or 2 parameters
        echo '$0 [launch | delete] pod_name'
        echo '$0 [launch | delete]'
}

launch () { 
        output_file=$output_dir/$stackname-output.json
        template_file=$output_dir/kubernetes-nodes.yaml
        #aws cloudformation deploy --template-file $template_file --stack-name $stackname --parameter-overrides ParameterKey=KeyNameParam,ParameterValue=$keypair
        if [ $? == 0 ]
        then 
                aws cloudformation describe-stacks --stack-name $stackname | jq '.["Stacks"][]["Outputs"]' | tee $output_file
                masterip=$(cat $output_file | jq -r '.[] | select(.OutputKey=="AdmPublicIP") | .OutputValue')
                nodeip=$(cat $output_file | jq -r '.[] | select(.OutputKey=="NodePublicIP") | .OutputValue')
                echo master ip = $masterip
                echo node ip = $nodeip
                sleep 2
                scp -i $ssh_key -o "StrictHostKeyChecking=no" $output_dir/userdata-check.sh ec2-user@$masterip:/tmp/userdata-check.sh > /dev/null
                command=$(ssh -i $ssh_key -o "StrictHostKeyChecking=no" ec2-user@$masterip "chmod 754 /tmp/userdata-check.sh; /tmp/userdata-check.sh")
                if [ $? == 0 ]
                then 
                        ssh -i $ssh_key -o "StrictHostKeyChecking=no" ec2-user@$nodeip "$command"
                else
                        echo error with user-data file: $command
                        exit 1
                fi
        else
                echo $stackname returned code $?
                exit 1
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
cp userdata-check.sh $output_dir
cp kubernetes-nodes.yaml $output_dir

if [ $# -eq 0 ]
then 
	note
	exit 1
fi

if [ $1 == "launch" ] || [ $1 == "delete" ]
then
        if [ $# -eq 1 ]
        then 
                read -p "what is the stack name? " stackname
                $1 $stackname
        elif [ $# -eq 2 ]
        then
                stackname=$2
                $1 $stackname
        else
                note
        fi
else
        note
fi
