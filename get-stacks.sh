echo Stacks not deleted \(blank means none\):

aws cloudformation list-stacks | jq '.[][] | select(.StackStatus != "DELETE_COMPLETE")'
