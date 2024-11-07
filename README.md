# Nginx Cache Test Harness

This test harness helps evaluate Nginx caching behavior for module federation components. It provides a containerized environment to test various caching scenarios and validate cache configuration settings.

## Prerequisites

- Docker (20.10.0 or higher)
- Docker Compose (2.0.0 or higher)
- Bash shell
- Git (for version control)

## Directory Structure

```
test-harness/
├── apps/              # Component libraries
│   ├── lib1.js
│   └── lib2.js
├── nginx/            # Nginx configuration
│   └── nginx.conf
├── tests/            # Test scripts
│   └── test_caching.sh
├── results/          # Test results output
├── docker-compose.yml
└── README.md
```

## Quick Start

1. Clone the repository or create a new directory:

```bash
mkdir nginx-cache-test
cd nginx-cache-test
```

2. Copy all the test harness files into your directory

```bash
# Copy the content of the bash script provided earlier
chmod +x setup.sh
./setup.sh
```

3. Start the test environment:

```bash
docker-compose up -d
```

4. Run the tests:

```bash
docker-compose run test
```

5. Check the results:

```bash
cat results/test_results.txt
```

## Test Scenarios

The test harness validates the following scenarios:

1. Initial Cache Miss
   - Verifies that the first request results in a cache miss
2. Cache Hit
   - Confirms subsequent requests are served from cache
3. Cache Bypass
   - Tests that cache can be bypassed when needed

## Nginx Configuration

The test harness uses the following key caching configurations:

- Cache Zone: 10MB
- Cache Valid Time: 60 minutes
- Cache Levels: 1:2
- Cache Key: `$scheme$request_method$host$request_uri`

### Debug Headers

The following debug headers are included in responses:

- `X-Cache-Status`: Shows cache hit/miss status
- `X-Cache-Key`: Shows the cache key used

## Customization

### Modifying Cache Settings

Edit `nginx/nginx.conf` to adjust cache parameters:

```nginx
proxy_cache_path /tmp/nginx_cache
    levels=1:2
    keys_zone=my_cache:10m
    max_size=10g
    inactive=60m
    use_temp_path=off;
```

### Adding Test Cases

1. Open `tests/test_caching.sh`
2. Add new test cases following the pattern:

```bash
echo "Testing new scenario..."
RESULT=$(curl -s -I "${BASE_URL}/libs/your-test-case" | grep "X-Cache-Status" | cut -d' ' -f2)
run_test "Test Description" "EXPECTED_VALUE" "${RESULT}"
```

## Troubleshooting

### Common Issues

1. Port Conflicts

```bash
# If port 8080 is in use, modify docker-compose.yml:
ports:
  - "8081:8080"  # Change to any available port
```

2. Permission Issues

```bash
# If experiencing permission issues with results directory:
chmod 777 results
```

3. Cache Not Working

```bash
# Check Nginx logs:
docker-compose logs nginx

# Verify cache directory exists:
docker-compose exec nginx ls /tmp/nginx_cache
```

### Health Checks

The environment includes a health check endpoint:

```bash
curl http://localhost:8080/health
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new features
4. Submit a pull request

## License

MIT License - feel free to modify and reuse for your own projects.

## Support

For issues and questions:

1. Check the troubleshooting section
2. Submit an issue on the repository
3. Review Nginx caching documentation
