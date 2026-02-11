# Dockerfile for 2019-standard NGINX server
FROM nginx:1.18-alpine

# Install OpenSSL for certificate operations
RUN apk add --no-cache openssl

# Create directories
RUN mkdir -p /etc/nginx/certs /var/cache/nginx

# Set working directory
WORKDIR /etc/nginx

# Expose ports
EXPOSE 80 443

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-check-certificate --quiet --tries=1 --spider https://localhost || exit 1

# Start NGINX
CMD ["nginx", "-g", "daemon off;"]
