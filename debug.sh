#!/bin/bash

# Debug script for Nginx container startup issues
echo "=== Starting Nginx Container Debug ==="

# 1. Check if nginx container exists
echo "Checking container status..."
docker ps -a | grep nginx

# 2. Check logs
echo -e "\n=== Nginx Container Logs ==="
docker logs test-harness-nginx-1

# 3. Verify nginx.conf syntax
echo -e "\n=== Checking Nginx Configuration Syntax ==="
docker exec -i test-harness-nginx-1 nginx -t 2>/dev/null || echo "Container not running, testing config in new container..."

# 4. Check file permissions and existence
echo -e "\n=== Checking File Permissions and Existence ==="
echo "Current directory structure:"
ls -la

echo -e "\nNginx configuration file:"
ls -la nginx/nginx.conf

# 5. Test nginx config in temporary container
echo -e "\n=== Testing Nginx Config in Clean Container ==="
docker run --rm -v $(pwd)/nginx/nginx.conf:/etc/nginx/nginx.conf:ro nginx:alpine nginx -t

# 6. Check port availability
echo -e "\n=== Checking Port Availability ==="
if command -v netstat &> /dev/null; then
    netstat -tuln | grep 8080
else
    echo "netstat not found, trying ss command..."
    ss -tuln | grep 8080
fi

# Clean up any stopped containers
echo -e "\n=== Cleaning up stopped containers ==="
docker rm -f test-harness-nginx-1 2>/dev/null

# Recreate with debug mode
echo -e "\n=== Attempting to start Nginx with debug mode ==="
cat > docker-compose.debug.yml << EOL
version: '3'
services:
  nginx:
    image: nginx:alpine
    ports:
      - "8080:8080"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./apps:/usr/share/nginx/html/libs
    command: ["nginx-debug", "-g", "daemon off;"]
    environment:
      - NGINX_ENTRYPOINT_QUIET_LOGS=
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 10s
      timeout: 5s
      retries: 3

  test:
    image: curlimages/curl:latest
    depends_on:
      nginx:
        condition: service_healthy
    volumes:
      - ./tests:/tests
      - ./results:/results
    command: ["sh", "-c", "cd /tests && sh test_caching.sh > /results/test_results.txt"]
EOL

# Updated nginx.conf with more permissive settings
cat > nginx/nginx.conf << EOL
worker_processes  1;
error_log  /var/log/nginx/error.log debug;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    proxy_cache_path /tmp/nginx_cache 
                    levels=1:2 
                    keys_zone=my_cache:10m 
                    max_size=10g 
                    inactive=60m 
                    use_temp_path=off;
    
    server {
        listen 8080;
        server_name localhost;
        
        location /libs/ {
            root /usr/share/nginx/html;
            proxy_cache my_cache;
            proxy_cache_use_stale error timeout http_500 http_502 http_503 http_504;
            proxy_cache_valid 200 60m;
            proxy_cache_key \$scheme\$request_method\$host\$request_uri;
            
            add_header X-Cache-Status \$upstream_cache_status;
            add_header X-Cache-Key \$scheme\$request_method\$host\$request_uri;
            
            expires 1h;
            add_header Cache-Control "public, no-transform";
        }
        
        location /health {
            access_log off;
            add_header 'Content-Type' 'text/plain';
            return 200 'healthy\n';
        }
    }
}
EOL

echo -e "\n=== Starting containers with debug configuration ==="
docker-compose -f docker-compose.debug.yml up -d

echo -e "\n=== Waiting for container to start ==="
sleep 5

echo -e "\n=== New container logs ==="
docker logs test-harness-nginx-1

echo -e "\n=== Debug complete ==="
echo "If the container is still failing, check the logs above for specific error messages"
echo "You can also manually inspect the logs with: docker logs test-harness-nginx-1"