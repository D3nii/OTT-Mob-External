#!/usr/bin/env bash

PUBSPEC_FILE="pubspec.yaml"
if [ ! -f "$PUBSPEC_FILE" ]; then
    echo "Error: pubspec.yaml not found" >&2
    exit 1
fi

VERSION=$(grep "^version:" "$PUBSPEC_FILE" | sed 's/version: *//' | sed 's/+.*//')
if [ -z "$VERSION" ]; then
    echo "Error: Could not extract version from pubspec.yaml" >&2
    exit 1
fi

echo "$VERSION"
