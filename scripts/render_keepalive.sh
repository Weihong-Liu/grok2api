#!/usr/bin/env sh
set -eu

KEEPALIVE_URL="${KEEPALIVE_URL:-}"
PING_TIMEOUT="${PING_TIMEOUT:-30}"
RETRY_COUNT="${RETRY_COUNT:-3}"
RETRY_DELAY="${RETRY_DELAY:-10}"

if [ -z "$KEEPALIVE_URL" ]; then
  echo "KEEPALIVE_URL is required, e.g. https://your-service.onrender.com/health" >&2
  exit 1
fi

case "$KEEPALIVE_URL" in
  http://*|https://*)
    ;;
  *)
    echo "KEEPALIVE_URL must start with http:// or https://" >&2
    exit 1
    ;;
esac

attempt=1
while [ "$attempt" -le "$RETRY_COUNT" ]; do
  if curl --fail --silent --show-error --max-time "$PING_TIMEOUT" --output /dev/null "$KEEPALIVE_URL"; then
    echo "Keepalive succeeded: $KEEPALIVE_URL"
    exit 0
  fi

  if [ "$attempt" -lt "$RETRY_COUNT" ]; then
    echo "Keepalive attempt $attempt failed, retrying in ${RETRY_DELAY}s..." >&2
    sleep "$RETRY_DELAY"
  fi

  attempt=$((attempt + 1))
done

echo "Keepalive failed after $RETRY_COUNT attempts: $KEEPALIVE_URL" >&2
exit 1
