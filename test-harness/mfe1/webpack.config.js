const HtmlWebpackPlugin = require('html-webpack-plugin');
const ModuleFederationPlugin = require('webpack/lib/container/ModuleFederationPlugin');
const path = require('path');

module.exports = {
  entry: './src/bootstrap.js',
  output: {
    path: path.resolve(__dirname, '../dist/mfe1'),
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
      name: 'mfe1',
      filename: 'remoteEntry.js',
      exposes: {
        './App': './src/App',
      },
      shared: {
        '@mui/material': { 
          singleton: false,
          requiredVersion: '5.13.7',
          eager: false
        },
        '@mui/system': { 
          singleton: false,
          requiredVersion: '5.13.7',
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
