# Stage 1: Build static assets (if using Sass, PostCSS, etc.) - skipped here
# Just copying public files

# Stage 2: Nginx for serving static assets
FROM nginx:alpine

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d

# Copy public assets
COPY public/ /usr/share/nginx/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
