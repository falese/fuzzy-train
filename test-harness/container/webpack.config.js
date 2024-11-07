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
