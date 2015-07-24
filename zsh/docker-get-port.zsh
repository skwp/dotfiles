# Usage: docker-get-port (name|sha) port/protocol
[ -n "$1" ] && docker inspect $1 | jq -r ".[0] | .NetworkSettings | .Ports | .[\"$2\"] | .[0] | .HostPort"

