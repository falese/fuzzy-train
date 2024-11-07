#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}Updating MFEs with Material UI versions...${NC}"

# Create the base directory structure if it doesn't exist
mkdir -p test-harness/{mfe1,mfe2,mfe3}/src

# MFE1 package.json - v5.13.7
cat > test-harness/mfe1/package.json << EOL
{
  "name": "mfe1",
  "version": "1.0.0",
  "scripts": {
    "build": "webpack --mode production",
    "start": "webpack serve --mode development"
  },
  "dependencies": {
    "@mui/material": "5.13.7",
    "@mui/system": "5.13.7",
    "@emotion/react": "^11.11.0",
    "@emotion/styled": "^11.11.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@babel/core": "^7.22.20",
    "@babel/preset-react": "^7.22.15",
    "@babel/preset-env": "^7.22.20",
    "babel-loader": "^9.1.3",
    "webpack": "^5.88.2",
    "webpack-cli": "^5.1.4",
    "webpack-dev-server": "^4.15.1",
    "html-webpack-plugin": "^5.5.3"
  }
}
EOL

# MFE2 package.json - v5.14.7
cat > test-harness/mfe2/package.json << EOL
{
  "name": "mfe2",
  "version": "1.0.0",
  "scripts": {
    "build": "webpack --mode production",
    "start": "webpack serve --mode development"
  },
  "dependencies": {
    "@mui/material": "5.14.7",
    "@mui/system": "5.14.7",
    "@emotion/react": "^11.11.0",
    "@emotion/styled": "^11.11.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@babel/core": "^7.22.20",
    "@babel/preset-react": "^7.22.15",
    "@babel/preset-env": "^7.22.20",
    "babel-loader": "^9.1.3",
    "webpack": "^5.88.2",
    "webpack-cli": "^5.1.4",
    "webpack-dev-server": "^4.15.1",
    "html-webpack-plugin": "^5.5.3"
  }
}
EOL

# MFE3 package.json - v5.15.1
cat > test-harness/mfe3/package.json << EOL
{
  "name": "mfe3",
  "version": "1.0.0",
  "scripts": {
    "build": "webpack --mode production",
    "start": "webpack serve --mode development"
  },
  "dependencies": {
    "@mui/material": "5.15.1",
    "@mui/system": "5.15.1",
    "@emotion/react": "^11.11.0",
    "@emotion/styled": "^11.11.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@babel/core": "^7.22.20",
    "@babel/preset-react": "^7.22.15",
    "@babel/preset-env": "^7.22.20",
    "babel-loader": "^9.1.3",
    "webpack": "^5.88.2",
    "webpack-cli": "^5.1.4",
    "webpack-dev-server": "^4.15.1",
    "html-webpack-plugin": "^5.5.3"
  }
}
EOL

# Update webpack configs for each MFE
for mfe in mfe1 mfe2 mfe3
do
cat > test-harness/$mfe/webpack.config.js << EOL
const HtmlWebpackPlugin = require('html-webpack-plugin');
const ModuleFederationPlugin = require('webpack/lib/container/ModuleFederationPlugin');
const path = require('path');

module.exports = {
  entry: './src/bootstrap.js',
  output: {
    path: path.resolve(__dirname, '../dist/$mfe'),
    publicPath: 'auto',
  },
  resolve: {
    extensions: ['.js', '.jsx', '.json'],
  },
  module: {
    rules: [
      {
        test: /\.jsx?$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: [
              '@babel/preset-env',
              ['@babel/preset-react', { "runtime": "automatic" }]
            ],
          },
        },
      },
    ],
  },
  plugins: [
    new ModuleFederationPlugin({
      name: '$mfe',
      filename: 'remoteEntry.js',
      exposes: {
        './App': './src/App',
      },
      shared: {
        react: { 
          singleton: true, 
          requiredVersion: '^18.2.0',
          eager: true
        },
        'react-dom': { 
          singleton: true, 
          requiredVersion: '^18.2.0',
          eager: true
        },
        '@mui/material': { 
          singleton: false,
          eager: true
        },
        '@mui/system': {
          singleton: false,
          eager: true
        },
        '@emotion/react': { 
          singleton: true,
          eager: true
        },
        '@emotion/styled': { 
          singleton: true,
          eager: true
        }
      },
    }),
    new HtmlWebpackPlugin({
      template: './src/index.html',
    }),
  ],
};
EOL

# Create bootstrap.js for each MFE
cat > test-harness/$mfe/src/bootstrap.js << EOL
import App from './App';

export default App;
EOL

# Create App component for each MFE
cat > test-harness/$mfe/src/App.jsx << EOL
import * as React from 'react';
import Button from '@mui/material/Button';
import { createTheme, ThemeProvider } from '@mui/material/styles';

const theme = createTheme({
  palette: {
    primary: {
      main: '${mfe: -1}' === '1' ? '#2196F3' : 
            '${mfe: -1}' === '2' ? '#4CAF50' : '#FF9800',
    },
  },
});

const App = () => {
  const muiVersion = require('@mui/material/package.json').version;
  
  return (
    <ThemeProvider theme={theme}>
      <div style={{ padding: '20px', border: '1px solid #ccc', margin: '10px' }}>
        <h3>${mfe} using MUI {muiVersion}</h3>
        <Button
          variant="contained"
          color="primary"
          onClick={() => alert('${mfe} button clicked! Using MUI ' + muiVersion)}
        >
          MUI Button
        </Button>
      </div>
    </ThemeProvider>
  );
};

export default App;
EOL

# Create index.html
cat > test-harness/$mfe/src/index.html << EOL
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

# Update container application
mkdir -p test-harness/container/src

cat > test-harness/container/package.json << EOL
{
  "name": "container",
  "version": "1.0.0",
  "scripts": {
    "build": "webpack --mode production",
    "start": "webpack serve --mode development"
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
  entry: './src/bootstrap.js',
  output: {
    path: path.resolve(__dirname, '../dist/container'),
    publicPath: 'auto',
  },
  resolve: {
    extensions: ['.js', '.jsx', '.json'],
  },
  module: {
    rules: [
      {
        test: /\.jsx?$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: [
              '@babel/preset-env',
              ['@babel/preset-react', { "runtime": "automatic" }]
            ],
          },
        },
      },
    ],
  },
  plugins: [
    new ModuleFederationPlugin({
      name: 'container',
      remotes: {
        mfe1: 'mfe1@/mfe1/remoteEntry.js',
        mfe2: 'mfe2@/mfe2/remoteEntry.js',
        mfe3: 'mfe3@/mfe3/remoteEntry.js',
      },
      shared: {
        react: { 
          singleton: true, 
          requiredVersion: '^18.2.0',
          eager: true
        },
        'react-dom': { 
          singleton: true, 
          requiredVersion: '^18.2.0',
          eager: true
        }
      },
    }),
    new HtmlWebpackPlugin({
      template: './src/index.html',
    }),
  ],
};
EOL

cat > test-harness/container/src/bootstrap.js << EOL
import('./index');
EOL

cat > test-harness/container/src/App.jsx << EOL
import React, { Suspense } from 'react';

const MFE1 = React.lazy(() => import('mfe1/App'));
const MFE2 = React.lazy(() => import('mfe2/App'));
const MFE3 = React.lazy(() => import('mfe3/App'));

const App = () => {
  return (
    <div style={{ padding: '20px' }}>
      <h1>MUI Version Testing</h1>
      <div style={{ marginBottom: '20px' }}>
        <h2>Testing different MUI versions:</h2>
        <ul>
          <li>MFE1: MUI v5.13.7</li>
          <li>MFE2: MUI v5.14.7</li>
          <li>MFE3: MUI v5.15.1</li>
        </ul>
      </div>
      <div>
        <Suspense fallback={<div>Loading MFE1...</div>}>
          <MFE1 />
        </Suspense>
        <Suspense fallback={<div>Loading MFE2...</div>}>
          <MFE2 />
        </Suspense>
        <Suspense fallback={<div>Loading MFE3...</div>}>
          <MFE3 />
        </Suspense>
      </div>
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

cat > test-harness/container/src/index.html << EOL
<!DOCTYPE html>
<html>
<head>
    <title>MUI Version Testing</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
        }
    </style>
</head>
<body>
    <div id="root"></div>
</body>
</html>
EOL

echo -e "${GREEN}MFE updates complete!${NC}"
echo "To apply changes:"
echo "1. cd test-harness"
echo "2. ./build.sh"
echo "3. Access http://localhost:8080"
echo ""
echo "Each MFE now uses a different MUI version with a Button component."
echo "Check Network tab to verify caching of MUI resources."