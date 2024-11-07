#!/bin/bash

# Build all MFEs
for app in mfe1 mfe2 mfe3 container; do
    echo "Building $app..."
    cd $app
    npm install
    npm run build
    cd ..
done

# Start Docker containers
docker-compose up -d

echo "Build complete! Access the application at http://localhost:8080"
echo "Check the browser's Network tab to verify caching of shared libraries"
