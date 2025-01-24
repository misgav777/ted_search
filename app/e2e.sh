#!/bin/bash

# Variables
APP_URL="http://localhost"
CACHE_ENDPOINT="http://localhost/cache-test" # Example endpoint for testing caching
RESPONSE_TIME_THRESHOLD=1.0 # Response time threshold in seconds

echo "Starting E2E test..."

# Function to test HTTP status
check_http_status() {
  local url=$1
  echo "Testing HTTP status for $url..."

  # Perform a GET request and capture the HTTP status code
  status_code=$(curl -o /dev/null -s -w "%{http_code}" "$url")

  if [ "$status_code" -eq 200 ]; then
    echo "✅ $url is reachable (HTTP $status_code)"
  else
    echo "❌ $url is not reachable (HTTP $status_code)"
    exit 1
  fi
}

# Function to test response time
check_response_time() {
  local url=$1
  echo "Testing response time for $url..."

  # Measure the response time
  response_time=$(curl -o /dev/null -s -w "%{time_total}" "$url")
  echo "Response time: $response_time seconds"

  # Compare with the threshold
  if (( $(echo "$response_time > $RESPONSE_TIME_THRESHOLD" | bc -l) )); then
    echo "❌ Response time for $url exceeded threshold ($RESPONSE_TIME_THRESHOLD seconds)"
    exit 1
  else
    echo "✅ Response time for $url is within threshold"
  fi
}

# Run tests
check_http_status "$APP_URL"

# Optional: Verify caching by testing response time
if [ -n "$CACHE_ENDPOINT" ]; then
  echo "Testing caching behavior..."
  check_response_time "$CACHE_ENDPOINT"
fi

echo "✅ All E2E tests passed!"
