Backend environment and Kubernetes

- The repository includes `backend/.env.docker.example` as a reference. It intentionally contains placeholders for secrets.
- The `backend/Dockerfile` no longer requires `.env.docker` at build time. Runtime configuration should be provided with Kubernetes ConfigMap (`backend-config`) and Secret (`backend-secret`), or by passing env vars to `docker run`.
- The image includes an entrypoint script (`/app/entrypoint.sh`) that will write runtime env vars into `/app/.env` before starting the app, if they are present.

Creating the backend secret in kubernetes (example):

kubectl create secret generic backend-secret \
  --namespace wanderlust \
  --from-literal=MONGODB_URI='mongodb://mongo-service/wanderlust' \
  --from-literal=REDIS_URL='redis://redis-service:6379' \
  --from-literal=JWT_SECRET='your-jwt-secret'
