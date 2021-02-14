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
