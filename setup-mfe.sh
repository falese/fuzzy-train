#!/bin/bash

# Create base directory structure
mkdir -p test-harness/{container,mfe1,mfe2,mfe3,shared-lib/{v1,v2,v3},nginx}

# Create package.json files for each application
for app in container mfe1 mfe2 mfe3
do
cat > test-harness/$app/package.json << EOL
{
  "name": "$app",
  "version": "1.0.0",
  "scripts": {
    "start": "webpack serve",
    "build": "webpack --mode production"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@babel/core": "^7.22.20",
    "@babel/preset-react": "^7.22.15",
    "@babel/preset-env": "^7.22.20",
    "babel-loader": "^9.1.3",
    "html-webpack-plugin": "^5.5.3",
    "webpack": "^5.88.2",
    "webpack-cli": "^5.1.4",
    "webpack-dev-server": "^4.15.1"
  }
}
EOL
done

# Create webpack configs for each MFE
for mfe in mfe1 mfe2 mfe3
do
cat > test-harness/$mfe/webpack.config.js << EOL
const HtmlWebpackPlugin = require('html-webpack-plugin');
const ModuleFederationPlugin = require('webpack/lib/container/ModuleFederationPlugin');
const path = require('path');

const version = '${mfe: -1}'; // Extract version number from MFE name

module.exports = {
  entry: './src/index.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    publicPath: 'http://localhost:308${mfe: -1}/', // Each MFE gets its own port
  },
  mode: 'development',
  devServer: {
    port: 308${mfe: -1},
    historyApiFallback: true,
  },
  module: {
    rules: [
      {
        test: /\.jsx?$/,
        loader: 'babel-loader',
        exclude: /node_modules/,
        options: {
          presets: ['@babel/preset-react'],
        },
      },
    ],
  },
  plugins: [
    new ModuleFederationPlugin({
      name: '${mfe}',
      filename: 'remoteEntry.js',
      exposes: {
        './App': './src/App',
      },
      shared: {
        react: { singleton: true, requiredVersion: '^18.2.0' },
        'react-dom': { singleton: true, requiredVersion: '^18.2.0' },
        'shared-lib': { singleton: false }, // Allow multiple versions
      },
    }),
    new HtmlWebpackPlugin({
      template: './public/index.html',
    }),
  ],
};
EOL

# Create source files for each MFE
mkdir -p test-harness/$mfe/{src,public}
cat > test-harness/$mfe/src/App.js << EOL
import React from 'react';
import { sharedLib } from 'shared-lib';

const App = () => {
  return (
    <div style={{ border: '1px solid #ccc', padding: '20px', margin: '10px' }}>
      <h2>${mfe} Component</h2>
      <p>Using shared-lib version {sharedLib.version}</p>
      <div id="${mfe}-lib"></div>
    </div>
  );
};

export default App;
EOL

cat > test-harness/$mfe/src/index.js << EOL
import('./App');
EOL

cat > test-harness/$mfe/public/index.html << EOL
<!DOCTYPE html>
<html>
  <head>
    <title>${mfe}</title>
  </head>
  <body>
    <div id="root"></div>
  </body>
</html>
EOL
done

# Create webpack config for container
cat > test-harness/container/webpack.config.js << EOL
const HtmlWebpackPlugin = require('html-webpack-plugin');
const ModuleFederationPlugin = require('webpack/lib/container/ModuleFederationPlugin');
const path = require('path');

module.exports = {
  entry: './src/index.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    publicPath: 'http://localhost:3080/',
  },
  mode: 'development',
  devServer: {
    port: 3080,
    historyApiFallback: true,
  },
  module: {
    rules: [
      {
        test: /\.jsx?$/,
        loader: 'babel-loader',
        exclude: /node_modules/,
        options: {
          presets: ['@babel/preset-react'],
        },
      },
    ],
  },
  plugins: [
    new ModuleFederationPlugin({
      name: 'container',
      remotes: {
        mfe1: 'mfe1@http://localhost:3081/remoteEntry.js',
        mfe2: 'mfe2@http://localhost:3082/remoteEntry.js',
        mfe3: 'mfe3@http://localhost:3083/remoteEntry.js',
      },
      shared: {
        react: { singleton: true, requiredVersion: '^18.2.0' },
        'react-dom': { singleton: true, requiredVersion: '^18.2.0' },
        'shared-lib': { singleton: false }, // Allow multiple versions
      },
    }),
    new HtmlWebpackPlugin({
      template: './public/index.html',
    }),
  ],
};
EOL

# Create container app files
mkdir -p test-harness/container/{src,public}
cat > test-harness/container/src/App.js << EOL
import React, { Suspense } from 'react';

const MFE1 = React.lazy(() => import('mfe1/App'));
const MFE2 = React.lazy(() => import('mfe2/App'));
const MFE3 = React.lazy(() => import('mfe3/App'));

const App = () => {
  return (
    <div>
      <h1>Microfrontend Container</h1>
      <Suspense fallback="Loading MFE1...">
        <MFE1 />
      </Suspense>
      <Suspense fallback="Loading MFE2...">
        <MFE2 />
      </Suspense>
      <Suspense fallback="Loading MFE3...">
        <MFE3 />
      </Suspense>
    </div>
  );
};

export default App;
EOL

cat > test-harness/container/src/index.js << EOL
import React from 'react';
import { createRoot } from 'react-dom/client';
import App from './App';

const container = document.getElementById('root');
const root = createRoot(container);
root.render(<App />);
EOL

cat > test-harness/container/public/index.html << EOL
<!DOCTYPE html>
<html>
  <head>
    <title>Module Federation Container</title>
  </head>
  <body>
    <div id="root"></div>
  </body>
</html>
EOL

# Create shared library versions
for version in 1 2 3
do
cat > test-harness/shared-lib/v$version/index.js << EOL
export const sharedLib = {
  version: '$version.0.0',
  render: function(containerId) {
    const element = document.createElement('div');
    element.textContent = \`Shared Library Version $version.0.0 Loaded\`;
    document.getElementById(containerId).appendChild(element);
  }
};
EOL
done

# Create .gitignore
cat > test-harness/.gitignore << EOL
node_modules
dist
EOL

# Update nginx.conf to handle module federation
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
                     '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    proxy_cache_path /tmp/nginx_cache 
                    levels=1:2 
                    keys_zone=shared_lib_cache:10m 
                    max_size=10g 
                    inactive=60m 
                    use_temp_path=off;

    server {
        listen 8080;
        server_name localhost;

        # Container application
        location / {
            proxy_pass http://localhost:3080;
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host \$host;
        }

        # MFE1
        location /mfe1/ {
            proxy_pass http://localhost:3081/;
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host \$host;
        }

        # MFE2
        location /mfe2/ {
            proxy_pass http://localhost:3082/;
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host \$host;
        }

        # MFE3
        location /mfe3/ {
            proxy_pass http://localhost:3083/;
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host \$host;
        }

        # Shared library versions with caching
        location /libs/ {
            root /usr/share/nginx/html;
            proxy_cache shared_lib_cache;
            proxy_cache_use_stale error timeout http_500 http_502 http_503 http_504;
            proxy_cache_valid 200 60m;
            proxy_cache_key "\$scheme\$request_method\$host\$request_uri";
            add_header X-Cache-Status \$upstream_cache_status;
            expires 1h;
            add_header Cache-Control "public, no-transform";
        }
    }
}
EOL

echo "Module Federation setup complete!"
echo "
To start the applications:
1. For each directory (container, mfe1, mfe2, mfe3):
   cd [directory]
   npm install
   npm start

2. Access the container at http://localhost:3080
"