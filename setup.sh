#!/bin/bash

# Create base directory structure
mkdir -p test-harness/{container,mfe1,mfe2,mfe3,shared-lib/{v1,v2,v3},nginx,dist}

# Create shared library versions with proper versioning
for version in 1 2 3
do
cat > test-harness/shared-lib/v$version/shared.js << EOL
(function() {
    console.log('Loading shared library v$version.0.0');
    window.sharedLib_v$version = {
        version: '$version.0.0',
        render: function(containerId, data) {
            console.log('Rendering with shared lib v$version.0.0');
            const element = document.createElement('div');
            element.textContent = \`Rendered by Shared Library v$version.0.0 - \${data}\`;
            document.getElementById(containerId).appendChild(element);
            // Add a timestamp to verify caching
            const timestamp = document.createElement('div');
            timestamp.style.fontSize = '0.8em';
            timestamp.style.color = '#666';
            timestamp.textContent = \`Loaded at: \${new Date().toISOString()}\`;
            document.getElementById(containerId).appendChild(timestamp);
        }
    };
})();
EOL
done

# Create webpack config for MFEs
for mfe in mfe1 mfe2 mfe3
do
mkdir -p test-harness/$mfe/src
version=${mfe: -1}

cat > test-harness/$mfe/package.json << EOL
{
  "name": "$mfe",
  "version": "1.0.0",
  "scripts": {
    "build": "webpack --mode production",
    "start": "webpack serve --mode development"
  },
  "dependencies": {},
  "devDependencies": {
    "webpack": "^5.88.2",
    "webpack-cli": "^5.1.4",
    "webpack-dev-server": "^4.15.1",
    "html-webpack-plugin": "^5.5.3"
  }
}
EOL

cat > test-harness/$mfe/webpack.config.js << EOL
const HtmlWebpackPlugin = require('html-webpack-plugin');
const ModuleFederationPlugin = require('webpack/lib/container/ModuleFederationPlugin');
const path = require('path');

module.exports = {
  entry: './src/index.js',
  output: {
    path: path.resolve(__dirname, '../dist/$mfe'),
    publicPath: 'auto',
  },
  mode: 'production',
  plugins: [
    new ModuleFederationPlugin({
      name: '$mfe',
      filename: 'remoteEntry.js',
      exposes: {
        './App': './src/index',
      },
    }),
    new HtmlWebpackPlugin({
      template: './src/index.html',
    }),
  ],
};
EOL

cat > test-harness/$mfe/src/index.html << EOL
<!DOCTYPE html>
<html>
<head>
    <title>$mfe</title>
    <!-- Load the shared library from Nginx cached version -->
    <script src="/libs/v$version/shared.js"></script>
</head>
<body>
    <div id="$mfe-root"></div>
</body>
</html>
EOL

cat > test-harness/$mfe/src/index.js << EOL
const mount = (containerId) => {
    // Use the version-specific shared library
    if (window.sharedLib_v$version) {
        window.sharedLib_v$version.render(containerId, 'Mounted from $mfe');
    } else {
        console.error('Shared library v$version not loaded!');
    }
};

// Export mount function
export { mount };

// Mount if in standalone mode
if (!window.__POWERED_BY_FEDERATION__) {
    mount('$mfe-root');
}
EOL
done

# Create container application
mkdir -p test-harness/container/src

cat > test-harness/container/package.json << EOL
{
  "name": "container",
  "version": "1.0.0",
  "scripts": {
    "build": "webpack --mode production",
    "start": "webpack serve --mode development"
  },
  "devDependencies": {
    "webpack": "^5.88.2",
    "webpack-cli": "^5.1.4",
    "webpack-dev-server": "^4.15.1",
    "html-webpack-plugin": "^5.5.3"
  }
}
EOL

cat > test-harness/container/webpack.config.js << EOL
const HtmlWebpackPlugin = require('html-webpack-plugin');
const ModuleFederationPlugin = require('webpack/lib/container/ModuleFederationPlugin');
const path = require('path');

module.exports = {
  entry: './src/index.js',
  output: {
    path: path.resolve(__dirname, '../dist/container'),
    publicPath: 'auto',
  },
  mode: 'production',
  plugins: [
    new ModuleFederationPlugin({
      name: 'container',
      remotes: {
        mfe1: 'mfe1@/mfe1/remoteEntry.js',
        mfe2: 'mfe2@/mfe2/remoteEntry.js',
        mfe3: 'mfe3@/mfe3/remoteEntry.js',
      },
    }),
    new HtmlWebpackPlugin({
      template: './src/index.html',
    }),
  ],
};
EOL

cat > test-harness/container/src/index.html << EOL
<!DOCTYPE html>
<html>
<head>
    <title>MFE Container</title>
    <!-- Load all shared library versions -->
    <script src="/libs/v1/shared.js"></script>
    <script src="/libs/v2/shared.js"></script>
    <script src="/libs/v3/shared.js"></script>
    <style>
        .mfe-container {
            margin: 20px;
            padding: 20px;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        .cache-info {
            font-size: 0.8em;
            color: #666;
            margin-top: 10px;
        }
    </style>
</head>
<body>
    <h1>Microfrontend Container with Shared Library Caching</h1>
    
    <div class="mfe-container">
        <h2>MFE 1</h2>
        <div id="mfe1-container"></div>
    </div>
    
    <div class="mfe-container">
        <h2>MFE 2</h2>
        <div id="mfe2-container"></div>
    </div>
    
    <div class="mfe-container">
        <h2>MFE 3</h2>
        <div id="mfe3-container"></div>
    </div>

    <div class="cache-info">
        Check Network tab to see X-Cache-Status headers for shared library requests
    </div>
</body>
</html>
EOL

cat > test-harness/container/src/index.js << EOL
Promise.all([
    import('mfe1/App'),
    import('mfe2/App'),
    import('mfe3/App')
]).then(([mfe1, mfe2, mfe3]) => {
    mfe1.mount('mfe1-container');
    mfe2.mount('mfe2-container');
    mfe3.mount('mfe3-container');
}).catch(err => console.error('Error loading MFEs:', err));
EOL

# Update Nginx configuration
cat > test-harness/nginx/nginx.conf << EOL
worker_processes 1;
error_log /var/log/nginx/error.log debug;

events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                     '\$status \$body_bytes_sent "\$http_referer" '
                     '"$http_user_agent" "\$http_x_forwarded_for" '
                     'cache_status=\$upstream_cache_status';

    access_log /var/log/nginx/access.log main;

    # Cache configuration
    proxy_cache_path /tmp/nginx_cache 
                    levels=1:2 
                    keys_zone=shared_lib_cache:10m 
                    max_size=10g 
                    inactive=60m 
                    use_temp_path=off;

    server {
        listen 8080;
        server_name localhost;

        # Container and MFE static files
        location / {
            root /usr/share/nginx/html/dist/container;
            try_files \$uri \$uri/ /index.html;
        }

        location /mfe1/ {
            alias /usr/share/nginx/html/dist/mfe1/;
            try_files \$uri \$uri/ /index.html;
        }

        location /mfe2/ {
            alias /usr/share/nginx/html/dist/mfe2/;
            try_files \$uri \$uri/ /index.html;
        }

        location /mfe3/ {
            alias /usr/share/nginx/html/dist/mfe3/;
            try_files \$uri \$uri/ /index.html;
        }

        # Shared library versions with caching
        location /libs/ {
            root /usr/share/nginx/html;
            proxy_cache shared_lib_cache;
            proxy_cache_use_stale error timeout http_500 http_502 http_503 http_504;
            proxy_cache_valid 200 60m;
            proxy_cache_key "\$scheme\$request_method\$host\$request_uri";
            add_header X-Cache-Status \$upstream_cache_status;
            add_header Cache-Control "public, max-age=3600";
            expires 1h;
            
            # CORS headers
            add_header 'Access-Control-Allow-Origin' '*';
            add_header 'Access-Control-Allow-Methods' 'GET, OPTIONS';
            add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
        }
    }
}
EOL

# Update docker-compose.yml
cat > test-harness/docker-compose.yml << EOL
version: '3'
services:
  nginx:
    image: nginx:alpine
    ports:
      - "8080:8080"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./dist:/usr/share/nginx/html/dist
      - ./shared-lib:/usr/share/nginx/html/libs
    healthcheck:
      test: ["CMD", "wget", "-q", "--spider", "http://localhost:8080"]
      interval: 10s
      timeout: 5s
      retries: 3
EOL

# Create build script
cat > test-harness/build.sh << EOL
#!/bin/bash

# Build all MFEs
for app in mfe1 mfe2 mfe3 container; do
    echo "Building \$app..."
    cd \$app
    npm install
    npm run build
    cd ..
done

# Start Docker containers
docker-compose up -d

echo "Build complete! Access the application at http://localhost:8080"
echo "Check the browser's Network tab to verify caching of shared libraries"
EOL

chmod +x test-harness/build.sh

echo "Setup complete! To build and run:"
echo "1. cd test-harness"
echo "2. ./build.sh"
echo "3. Access http://localhost:8080"
echo ""
echo "To verify caching:"
echo "1. Open browser DevTools"
echo "2. Go to Network tab"
echo "3. Look for X-Cache-Status header in shared library requests"
echo "4. Refresh page to see MISS change to HIT for cached resources"