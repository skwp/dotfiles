# Usage: docker-get-ip (name or sha)
[ -n "$1" ] && docker inspect $1 | jq -r '.[0] | .NetworkSettings | .IPAddress'
