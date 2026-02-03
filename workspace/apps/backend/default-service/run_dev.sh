#!/bin/bash

# Build and Run the Server
echo "🔨 Building the project..."
./gradlew clean build -x test

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Build Successful!"
    echo "🚀 Starting Spring Boot Server..."
    ./gradlew bootRun
else
    echo "❌ Build Failed! Please check the logs."
    exit 1
fi
