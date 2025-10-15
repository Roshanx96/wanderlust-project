# ------------------- Stage 1: Build Stage ------------------------------
FROM node:21 AS frontend-builder

# It sets the working folder inside the container to /app
WORKDIR /app

# Copies only package.json and package-lock.json to /app.
# (These files contain the project’s dependencies.)
COPY package*.json ./

# Installs all the dependencies listed in the package.json
RUN npm install

# Copies the rest of your project files (like source code, config, etc.) into the container.
COPY . .

# ------------------- Stage 2: Final Stage ------------------------------
# Starts a new, smaller image (the “slim” version) of Node.js 21.
# It contains only what’s necessary to run the app — not the entire build tools.
FROM node:21-slim

# Set the working directory to /app
WORKDIR /app

# Copies all the built files and dependencies from the first stage (frontend-builder) into this smaller image.
# This avoids reinstalling everything and keeps the final image lightweight.
COPY --from=frontend-builder /app .

# Copy an optional entrypoint which can write runtime env vars into .env.local at container startup.
# We intentionally do not COPY .env.docker here so builds don't fail if the repository doesn't include
# environment files. Provide runtime env via k8s ConfigMap/Secret or mount a file if needed.
COPY ops/entrypoint.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh

# Expose port 5173 for the Node.js application
EXPOSE 5173

# Define the default command to run the application in development mode
# Defines what command to run when the container starts.
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["npm", "run", "dev", "--", "--host"]


