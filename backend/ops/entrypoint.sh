#!/bin/sh
# backend entrypoint
# Writes runtime environment variables into /app/.env if they are provided.

ENV_FILE="/app/.env"

echo "Starting backend entrypoint: checking runtime env vars..."

write_or_replace() {
  KEY="$1"
  VAL="$2"
  if [ -z "$VAL" ]; then
    return
  fi
  if [ ! -f "$ENV_FILE" ]; then
    touch "$ENV_FILE"
  fi
  if grep -q "^${KEY}=" "$ENV_FILE" 2>/dev/null; then
    sed -i "s|^${KEY}=.*|${KEY}=${VAL}|g" "$ENV_FILE"
  else
    echo "${KEY}=${VAL}" >> "$ENV_FILE"
  fi
}

# Non-exhaustive: include keys from .env.docker
write_or_replace "MONGODB_URI" "${MONGODB_URI}"
write_or_replace "REDIS_URL" "${REDIS_URL}"
write_or_replace "PORT" "${PORT}"
write_or_replace "FRONTEND_URL" "${FRONTEND_URL}"
write_or_replace "ACCESS_COOKIE_MAXAGE" "${ACCESS_COOKIE_MAXAGE}"
write_or_replace "ACCESS_TOKEN_EXPIRES_IN" "${ACCESS_TOKEN_EXPIRES_IN}"
write_or_replace "REFRESH_COOKIE_MAXAGE" "${REFRESH_COOKIE_MAXAGE}"
write_or_replace "REFRESH_TOKEN_EXPIRES_IN" "${REFRESH_TOKEN_EXPIRES_IN}"
write_or_replace "JWT_SECRET" "${JWT_SECRET}"
write_or_replace "NODE_ENV" "${NODE_ENV}"

exec "$@"
