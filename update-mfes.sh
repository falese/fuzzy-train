#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}Updating MFEs with Material UI versions and monitoring...${NC}"

# Create the base directory structure if it doesn't exist
mkdir -p test-harness/{container,mfe1,mfe2,mfe3}/src

# Create shared-lib directory if it doesn't exist
mkdir -p test-harness/shared-lib

# Create dependency monitor utility
cat > test-harness/shared-lib/monitor.js << EOL
window.depMonitor = {
  loads: {},
  log: function(name, version, source, loadTime) {
    this.loads[name] = {
      version,
      source,
      loadTime,
      timestamp: new Date().toISOString()
    };
    console.log(\`[Dep Monitor] \${name}@\${version} loaded from \${source} in \${loadTime}ms\`);
  }
};
EOL

# Container package.json
cat > test-harness/container/package.json << EOL
{
  "name": "container",
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

# Container webpack config with host-first setup
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
            presets: ['@babel/preset-env', ['@babel/preset-react', { "runtime": "automatic" }]],
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
        '@mui/material': { 
          singleton: false,
          requiredVersion: '5.13.7',
          eager: true,
          shareScope: 'default'
        },
        '@mui/system': { 
          singleton: false,
          requiredVersion: '5.13.7',
          eager: true,
          shareScope: 'default'
        },
        '@emotion/react': { 
          singleton: true,
          eager: true,
          shareScope: 'default'
        },
        '@emotion/styled': { 
          singleton: true,
          eager: true,
          shareScope: 'default'
        },
        'react': { 
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

# Container bootstrap and index files
cat > test-harness/container/src/bootstrap.js << EOL
import('./index');
EOL

cat > test-harness/container/src/index.js << EOL
import React from 'react';
import { createRoot } from 'react-dom/client';
import App from './App';

const container = document.getElementById('root');
const root = createRoot(container);
root.render(<App />);
EOL

# Container HTML template
cat > test-harness/container/src/index.html << EOL
<!DOCTYPE html>
<html>
<head>
    <title>MUI Version Testing</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
        }
    </style>
</head>
<body>
    <div id="root"></div>
</body>
</html>
EOL

# Create MFE configs with different MUI versions
for mfe in mfe1 mfe2 mfe3
do
  # Determine MUI version for this MFE
  MUI_VERSION="5.13.7"
  if [ "$mfe" = "mfe2" ]; then
    MUI_VERSION="5.14.7"
  elif [ "$mfe" = "mfe3" ]; then
    MUI_VERSION="5.15.1"
  fi

cat > test-harness/$mfe/package.json << EOL
{
  "name": "$mfe",
  "version": "1.0.0",
  "scripts": {
    "build": "webpack --mode production",
    "start": "webpack serve --mode development"
  },
  "dependencies": {
    "@mui/material": "$MUI_VERSION",
    "@mui/system": "$MUI_VERSION",
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
            presets: ['@babel/preset-env', ['@babel/preset-react', { "runtime": "automatic" }]],
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
        '@mui/material': { 
          singleton: false,
          requiredVersion: '$MUI_VERSION',
          eager: false
        },
        '@mui/system': { 
          singleton: false,
          requiredVersion: '$MUI_VERSION',
          eager: false
        },
        '@emotion/react': { 
          singleton: true,
          eager: false
        },
        '@emotion/styled': { 
          singleton: true,
          eager: false
        },
        'react': { 
          singleton: true,
          requiredVersion: '^18.2.0',
          eager: false
        },
        'react-dom': { 
          singleton: true,
          requiredVersion: '^18.2.0',
          eager: false
        }
      },
    }),
    new HtmlWebpackPlugin({
      template: './src/index.html',
    }),
  ],
};
EOL

# Create MFE bootstrap file
cat > test-harness/$mfe/src/bootstrap.js << EOL
import App from './App';
export default App;
EOL

# Create MFE index.html
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

# Create enhanced App component with dependency monitoring
cat > test-harness/$mfe/src/App.jsx << EOL
import * as React from 'react';
import Button from '@mui/material/Button';
import { createTheme, ThemeProvider } from '@mui/material/styles';
import Box from '@mui/material/Box';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import Typography from '@mui/material/Typography';
import CircularProgress from '@mui/material/CircularProgress';

const theme = createTheme({
  palette: {
    primary: {
      main: '${mfe: -1}' === '1' ? '#2196F3' : 
            '${mfe: -1}' === '2' ? '#4CAF50' : '#FF9800',
    },
  },
});

const App = () => {
  const [depInfo, setDepInfo] = React.useState({ loading: true });
  const startTime = React.useRef(Date.now());

  React.useEffect(() => {
    const muiVersion = require('@mui/material/package.json').version;
    const containerVersion = '5.13.7'; // Container's MUI version
    const loadTime = Date.now() - startTime.current;
    
    // Determine if using container's version
    const isUsingContainer = muiVersion === containerVersion;
    
    const info = {
      loading: false,
      version: muiVersion,
      source: isUsingContainer ? 'container' : 'local',
      loadTime
    };
    
    setDepInfo(info);
    
    // Log to console monitor
    console.log(\`[${mfe}] MUI \${muiVersion} loaded from \${info.source} in \${loadTime}ms\`);
    
    // Log performance mark
    performance.mark(\`${mfe}-mui-loaded\`);
  }, []);

  return (
    <ThemeProvider theme={theme}>
      <Card sx={{ minWidth: 275, mb: 2 }}>
        <CardContent>
          <Typography variant="h5" component="div">
            ${mfe}
          </Typography>
          {depInfo.loading ? (
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
              <CircularProgress size={20} />
              <Typography color="text.secondary">
                Loading dependencies...
              </Typography>
            </Box>
          ) : (
            <>
              <Typography color="text.secondary" gutterBottom>
                MUI Version: {depInfo.version}
              </Typography>
              <Typography color="text.secondary" gutterBottom>
                Source: {depInfo.source}
              </Typography>
              <Typography color="text.secondary" gutterBottom>
                Load Time: {depInfo.loadTime}ms
              </Typography>
              <Button
                variant="contained"
                color="primary"
                onClick={() => alert(\`${mfe} using MUI \${depInfo.version} from \${depInfo.source}\`)}
              >
                MUI Button
              </Button>
            </>
          )}
        </CardContent>
      </Card>
    </ThemeProvider>
  );
};

export default App;
EOL

done

# Update container App to include monitoring dashboard
cat > test-harness/container/src/App.jsx << EOL
import React, { Suspense } from 'react';
import { createTheme, ThemeProvider } from '@mui/material/styles';
import Box from '@mui/material/Box';
import Paper from '@mui/material/Paper';
import Typography from '@mui/material/Typography';

const MFE1 = React.lazy(() => import('mfe1/App'));
const MFE2 = React.lazy(() => import('mfe2/App'));
const MFE3 = React.lazy(() => import('mfe3/App'));

const theme = createTheme();

const LoadingFallback = () => (
  <Paper sx={{ p: 2, m: 1 }}>
    <Typography>Loading MFE...</Typography>
  </Paper>
);

const App = () => {
  return (
    <ThemeProvider theme={theme}>
      <Box sx={{ p: 3 }}>
        <Typography variant="h4" gutterBottom>
          MUI Version Testing with Dependency Monitoring
        </Typography>
        
        <Paper sx={{ p: 2, mb: 3 }}>
          <Typography variant="h6" gutterBottom>
            Container MUI Version: 5.13.7
          </Typography>
          <Typography variant="body2" color="text.secondary">
            Container provides shared dependencies with host-first configuration
          </Typography>
        </Paper>

        <Suspense fallback={<LoadingFallback />}>
          <MFE1 />
        </Suspense>
        
        <Suspense fallback={<LoadingFallback />}>
          <MFE2 />
        </Suspense>
        
        <Suspense fallback={<LoadingFallback />}>
          <MFE3 />
        </Suspense>

        <Paper sx={{ p: 2, mt: 3 }}>
          <Typography variant="body2" color="text.secondary">
            Check browser console for detailed dependency loading information
          </Typography>
        </Paper>
      </Box>
    </ThemeProvider>
  );
};

export default App;
EOL

echo -e "${GREEN}MFE updates complete!${NC}"
echo "To apply changes:"
echo "1. cd test-harness"
echo "2. ./build.sh"
echo "3. Access http://localhost:8080"
echo ""
echo "Features added:"
echo "- Host-first shared dependency configuration"
echo "- Dependency source tracking"
echo "- Load time monitoring"
echo "- Console logging"
echo "- Visual dependency information"
echo ""
echo "Check the browser console and UI for dependency loading details"