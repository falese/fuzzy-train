#!/bin/bash

# Create the proper directory structure
echo "Creating directory structure..."
mkdir -p test-harness/{nginx,apps,tests,results}
cd test-harness

# Create a valid nginx.conf
echo "Creating nginx configuration..."
cat > nginx/nginx.conf << 'EOL'
worker_processes 1;
error_log /var/log/nginx/error.log debug;

events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                     '$status $body_bytes_sent "$http_referer" '
                     '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

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
            
            # Fixed proxy_cache_key directive
            proxy_cache_key "$scheme$request_method$host$request_uri";
            
            add_header X-Cache-Status $upstream_cache_status;
            add_header X-Cache-Key "$scheme$request_method$host$request_uri";
            
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

# Create docker-compose.yml
echo "Creating Docker Compose configuration..."
cat > docker-compose.yml << 'EOL'
version: '3'
services:
  nginx:
    image: nginx:alpine
    ports:
      - "8080:8080"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./apps:/usr/share/nginx/html/libs
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

# Create a sample test file
echo "Creating test files..."
mkdir -p apps
echo "console.log('test file');" > apps/lib1.js

# Create test script
mkdir -p tests
cat > tests/test_caching.sh << 'EOL'
#!/bin/bash
echo "Running cache tests..."
curl -I http://nginx:8080/libs/lib1.js
EOL
chmod +x tests/test_caching.sh

# Ensure proper permissions
chmod 644 nginx/nginx.conf
chmod 644 docker-compose.yml

echo "Setup complete. Now run:"
echo "1. docker-compose down -v"
echo "2. docker-compose up -d"
echo "3. Check logs with: docker-compose logs nginx"
EOL

# Start fresh
docker-compose down -v 2>/dev/null

echo "Stopping any running containers and cleaning up..."
docker rm -f $(docker ps -aq) 2>/dev/null