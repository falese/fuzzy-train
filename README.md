# Module Federation with MUI Version Testing

This project demonstrates microfrontend architecture using Module Federation, with a focus on testing different versions of Material UI (MUI) across multiple microfrontends with dependency monitoring.

## Features

- Module Federation with host-first shared dependencies
- Multiple MUI versions running simultaneously
- Dependency source monitoring
- Performance tracking
- Nginx caching configuration

## Prerequisites

- Node.js (v14 or higher)
- Docker
- Docker Compose
- Git

## Directory Structure

```
test-harness/
├── container/          # Container application
├── mfe1/              # Microfrontend 1 (MUI v5.13.7)
├── mfe2/              # Microfrontend 2 (MUI v5.14.7)
├── mfe3/              # Microfrontend 3 (MUI v5.15.1)
├── nginx/             # Nginx configuration
├── shared-lib/        # Shared dependencies
└── docker-compose.yml
```

## Initial Setup

1. Create project directory and clone repository:

```bash
mkdir my-project
cd my-project
```

2. Set up the infrastructure:

```bash
# Create and run setup script
chmod +x setup.sh
./setup.sh
```

3. Add MUI versions and monitoring:

```bash
chmod +x update-mfes.sh
./update-mfes.sh
```

4. Build and start the application:

```bash
cd test-harness
./build.sh
```

5. Access the application:

- Main application: http://localhost:8080
- Check browser console for dependency monitoring

## Cleaning Up

To stop and clean up the environment:

```bash
cd test-harness
docker-compose down -v
rm -rf */node_modules
rm -rf dist
```

## Making Changes

### Updating MFE Configurations

1. Stop the current environment:

```bash
cd test-harness
docker-compose down -v
rm -rf */node_modules
rm -rf dist
cd ..
```

2. Run the update script:

```bash
./update-mfes.sh
```

3. Rebuild and start:

```bash
cd test-harness
./build.sh
```

### Adding New MFEs

1. Create new MFE directory in test-harness/
2. Update container's webpack.config.js to include new remote
3. Update docker-compose.yml if needed
4. Follow the cleanup and rebuild steps above

## Monitoring

### Dependency Information

- Check each MFE's card in the UI for:
  - MUI version in use
  - Dependency source (container/local)
  - Load time metrics

### Console Monitoring

- Open browser DevTools
- Check console for dependency loading information
- Performance marks available in Performance tab

### Performance Testing

- Network tab shows module loading
- Performance metrics in console
- Loading times displayed in UI

## Configuration Details

### Container (Host) Configuration

- Provides MUI v5.13.7 as shared dependency
- Uses host-first configuration
- Manages shared dependency loading

### MFE Configurations

- MFE1: MUI v5.13.7
- MFE2: MUI v5.14.7
- MFE3: MUI v5.15.1
- Each can fall back to local dependencies if needed

## Troubleshooting

### Common Issues

1. Build Failures

```bash
# Clean everything and rebuild
cd test-harness
./cleanup.sh
cd ..
./setup.sh
./update-mfes.sh
cd test-harness
./build.sh
```

2. Dependency Issues

```bash
# Remove node_modules and rebuild
cd test-harness
rm -rf */node_modules
npm install
./build.sh
```

3. Container not loading

- Check Docker containers: `docker-compose ps`
- Check logs: `docker-compose logs`
- Verify port 8080 is available

### Verification Steps

1. Check dependency loading:

- Open browser DevTools
- Look for console messages showing dependency sources
- Verify load times in UI

2. Verify MUI versions:

- Each MFE should show its version
- Container should show v5.13.7
- Check dependency source (container/local)

3. Monitor performance:

- Check Network tab for module loading
- Review console for timing information
- Verify load times in UI

## Scripts Reference

### setup.sh

- Sets up basic infrastructure
- Creates directory structure
- Configures Nginx

### update-mfes.sh

- Updates MFE configurations
- Adds MUI versions
- Configures monitoring

### build.sh

- Builds all applications
- Starts Docker containers
- Serves application

### cleanup.sh

- Stops containers
- Removes build artifacts
- Cleans node_modules

## Contributing

1. Create feature branch
2. Make changes
3. Test thoroughly
4. Submit pull request

## License

MIT License - See LICENSE file for details
