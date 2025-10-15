#!/bin/sh
# entrypoint.sh
# Writes runtime environment variables into .env.local if they are present.
# If VITE_API_PATH is provided at runtime, it will replace or add the line in .env.local

ENV_FILE="/app/.env.local"

echo "Starting entrypoint: checking runtime env vars..."

if [ -n "${VITE_API_PATH}" ]; then
  echo "VITE_API_PATH detected at runtime: ${VITE_API_PATH}"
  # Create .env.local if missing
  if [ ! -f "$ENV_FILE" ]; then
    touch "$ENV_FILE"
  fi

  # Use sed to replace or append the variable
  if grep -q "^VITE_API_PATH" "$ENV_FILE" 2>/dev/null; then
    sed -i "s|^VITE_API_PATH.*|VITE_API_PATH=\"${VITE_API_PATH}\"|g" "$ENV_FILE"
  else
    echo "VITE_API_PATH=\"${VITE_API_PATH}\"" >> "$ENV_FILE"
  fi
else
  echo "No VITE_API_PATH provided at runtime; leaving existing .env.local (if any)."
fi

exec "$@"
