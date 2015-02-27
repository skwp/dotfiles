# Usage: docker-get-id (friendly-name)
 [ -n "$1" ] && docker inspect $1 | jq -r '.[0] | .ID']
