#!/bin/bash
read -p "what is the stack name? " stackname

aws cloudformation delete-stack --stack-name $stackname 
if [ $? == 0 ]
then
        rm ~/cloudformation/$stackname-output.json
fi
