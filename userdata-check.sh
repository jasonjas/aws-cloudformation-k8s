wait_file() {
  local file="$1"
  local wait_seconds=$2 

  until test $((wait_seconds--)) -eq 0 -o -e "$file" ; do sleep 1; done

  ((++wait_seconds))
}
# Wait at most 240 seconds for the server.log file to appear
server_log=/var/log/user-data.log; 
wait_seconds=1
wait_file "$server_log" $wait_seconds || {
  echo "userdata log file missing after waiting for $wait_seconds seconds: '$server_log'"
  exit 1
}
cat $server_log
