# Stage 1
FROM node:21 AS backend-builder

# setup the working dir
WORKDIR /app

# code
COPY . .

# packages install
RUN npm i

# tests
RUN npm run test

# Stage 2
FROM node:21-slim

# setup the working dir
WORKDIR /app

# copy the above stage as compressed
COPY --from=backend-builder /app .

# Do not copy .env.docker at build time so builds don't fail when the repo doesn't contain env files.
# Runtime configuration should be provided with k8s ConfigMaps/Secrets or container env vars. The entrypoint
# will write runtime env values into /app/.env when present.
# Copy entrypoint script to allow runtime injection of env vars
COPY ops/entrypoint.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh

# Port
EXPOSE 8080

# App
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["npm", "start"]
