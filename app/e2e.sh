#!/bin/bash

# Configurations
APP_URL="http://localhost"
CACHE_ENDPOINT="http://localhost/cache-test" # Example endpoint for caching validation
RESPONSE_TIME_THRESHOLD=1.0 # Response time threshold in seconds
ENDPOINTS=("http://localhost" "http://localhost/health" "http://localhost/api/v1/resource")
LOG_FILE="e2e-test-results.log"
EXIT_CODE=0

echo "Starting E2E tests..." | tee -a $LOG_FILE

# Function to test HTTP status
check_http_status() {
  local url=$1
  echo "Testing HTTP status for $url..." | tee -a $LOG_FILE

  # Perform a GET request and capture the HTTP status code
  status_code=$(curl -o /dev/null -s -w "%{http_code}" "$url")

  if [ "$status_code" -eq 200 ]; then
    echo "✅ $url is reachable (HTTP $status_code)" | tee -a $LOG_FILE
  else
    echo "❌ $url is not reachable (HTTP $status_code)" | tee -a $LOG_FILE
    EXIT_CODE=1
  fi
}

# Function to test response time
check_response_time() {
  local url=$1
  echo "Testing response time for $url..." | tee -a $LOG_FILE

  # Measure the response time
  response_time=$(curl -o /dev/null -s -w "%{time_total}" "$url")
  echo "Response time: $response_time seconds" | tee -a $LOG_FILE

  # Compare with the threshold
  if (( $(echo "$response_time > $RESPONSE_TIME_THRESHOLD" | bc -l) )); then
    echo "❌ Response time for $url exceeded threshold ($RESPONSE_TIME_THRESHOLD seconds)" | tee -a $LOG_FILE
    EXIT_CODE=1
  else
    echo "✅ Response time for $url is within threshold" | tee -a $LOG_FILE
  fi
}

# Function to validate functional correctness
check_functional_response() {
  local url=$1
  local expected_value=$2
  echo "Testing functional response for $url..." | tee -a $LOG_FILE

  response=$(curl -s "$url")
  if [[ "$response" == *"$expected_value"* ]]; then
    echo "✅ Functional test passed for $url" | tee -a $LOG_FILE
  else
    echo "❌ Functional test failed for $url. Expected: $expected_value, Got: $response" | tee -a $LOG_FILE
    EXIT_CODE=1
  fi
}

# Test all endpoints
for endpoint in "${ENDPOINTS[@]}"; do
  check_http_status "$endpoint"
done

# Optional: Test response times for caching endpoint
if [ -n "$CACHE_ENDPOINT" ]; then
  echo "Testing caching behavior..." | tee -a $LOG_FILE
  check_response_time "$CACHE_ENDPOINT"
fi

# Add functional tests here
check_functional_response "http://localhost/api/v1/resource" "expected-value"

# Exit with appropriate code
if [ $EXIT_CODE -eq 0 ]; then
  echo "✅ All E2E tests passed!" | tee -a $LOG_FILE
else
  echo "❌ Some E2E tests failed. Check the log for details." | tee -a $LOG_FILE
fi

exit $EXIT_CODE
