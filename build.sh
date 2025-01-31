#!/bin/bash

# Define the directories for your Lambda functions
LAMBDA_DIRS=("create-contact" "get-contact" "dynamodb-trigger" "sns-trigger")

# Create the bin directory if it doesn't exist
mkdir -p bin

# Loop through each directory
for dir in "${LAMBDA_DIRS[@]}"; do
    # Navigate to the Lambda function directory
    cd "lambdas/$dir" || { echo "Directory lambdas/$dir not found"; exit 1; }

    # Compile the Go binary for Linux (ARM64 architecture, which is commonly used in AWS Lambda)
    GOOS=linux GOARCH=arm64 go build -o bootstrap main.go

    # Check if the build was successful
    if [ $? -ne 0 ]; then
        echo "Failed to build $dir"
        exit 1
    fi

    # Zip the binary into a deployment package named "$dir.zip" and place it in the bin directory
    zip "../../bin/$dir.zip" bootstrap

    # Remove the binary to clean up
    rm bootstrap

    # Navigate back to the root directory
    cd ../..
done

echo "All Lambda functions built and zipped successfully. ZIP files are in the 'bin' directory."