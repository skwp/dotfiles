# Usage: docker-get-state (friendly-name)
[ -n "$1" ] && docker inspect --format "{{ .State.Running }}" $1
