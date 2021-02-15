#!/bin/bash
read -p "what is the stack name? " stackname
output_file=~/cloudformation/$stackname-output.json
template_file=~/cloudformation/kubernetes-master-node.yaml
aws cloudformation deploy --template-file $template_file --stack-name $stackname 
if [ $? == 0 ]
then 
        aws cloudformation describe-stacks --stack-name $stackname | jq '.["Stacks"][]["Outputs"]' | tee $output_file
        masterip=$(cat $output_file | jq -r '.[] | select(.OutputKey=="AdmPublicIP") | .OutputValue')
        nodeip=$(cat $output_file | jq -r '.[] | select(.OutputKey=="NodePublicIP") | .OutputValue')
        echo master ip = $masterip
        echo node ip = $nodeip
        sleep 2
        scp -i ~/.ssh/aws-rsa -o "StrictHostKeyChecking=no" ~/cloudformation/userdata-check.sh ec2-user@$masterip:/tmp/userdata-check.sh > /dev/null
        command=$(ssh -i ~/.ssh/aws-rsa -o "StrictHostKeyChecking=no" ec2-user@$masterip "chmod 754 /tmp/userdata-check.sh; /tmp/userdata-check.sh")
        if [ $? == 0 ]
        then 
                ssh -i ~/.ssh/aws-rsa -o "StrictHostKeyChecking=no" ec2-user@$nodeip "$command"
        else
                echo error with user-data file: $command
        fi
else
        echo $stackname returned code $?
fi
