#!/bin/bash

output_dir=~/cloudformation
ssh_key=~/.ssh/aws-rsa

note () {
        echo accepts only 1 or 2 parameters
        echo '$0 [launch | delete] pod_name'
        echo '$0 [launch | delete]'
}

launch () { 
        output_file=$output_dir/$stackname-output.json
        template_file=$output_dir/kubernetes-nodes.yaml
        aws cloudformation deploy --template-file $template_file --stack-name $stackname 
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
        aws cloudformation delete-stack --stack-name $stackname
        if [ $? == 0 ]
        then
                rm $output_dir/$stackname-output.json
                fi
}

userdata () { cat <<EOF
	wait_file() {
	  local file="$1"; shift
	    local wait_seconds="${1:-10}"; shift # 10 seconds as default timeout

	      until test $((wait_seconds--)) -eq 0 -o -e "$file" ; do sleep 1; done

		((++wait_seconds))
	}
	# Wait at most 120 seconds for the server.log file to appear
	server_log=/var/log/user-data.log;
	wait_file "$server_log" 120 || {
		  echo "userdata log file missing after waiting for $? seconds: '$server_log'"
	  exit 1
	}
	cat $server_log
EOF
}

mkdir -p $output_dir
userdata > $output_dir/userdata-check.sh
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
