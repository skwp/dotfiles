# Usage: docker-get-id (friendly-name)
 [ -n "$1" ] && docker inspect --format "{{ .ID }}" $1

