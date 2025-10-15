Development and Docker environment variables

- The repository includes `frontend/.env.docker.example` as a reference. Do NOT commit secrets.
- The `frontend/Dockerfile` no longer requires `.env.docker` at build time. Provide runtime values via Kubernetes ConfigMap (`frontend-config`) or mount an env file.
- The image includes an entrypoint script (`/app/entrypoint.sh`) that writes `VITE_API_PATH` into `/app/.env.local` if the env var is present at container startup.

Local override:
- Create `frontend/.env.local` or `frontend/.env.docker` with `VITE_API_PATH="http://localhost:31100"` for local dev.
