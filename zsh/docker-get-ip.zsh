# Usage: docker-get-ip (name or sha)
[ -n "$1" ] && docker inspect --format "{{ .NetworkSettings.IPAddress }}" $1
