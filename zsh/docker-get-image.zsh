# Usage: docker-get-image (friendly-name)
[ -n "$1" ] && docker inspect --format "{{ .Image }}" $1
