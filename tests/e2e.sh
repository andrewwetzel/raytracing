#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Test the frontend
echo "Testing frontend..."
curl --fail http://localhost:8080 | grep "Pythagorean Theorem Calculator"

# Test the backend
echo "Testing backend..."
curl --fail "http://localhost:8000/hypotenuse?a=3&b=4" | grep "{\"hypotenuse\":5.0}"
