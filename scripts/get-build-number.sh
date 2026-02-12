#!/usr/bin/env bash

BUILD_NUMBER=$(grep "^version:" pubspec.yaml | sed -n 's/.*+\([0-9]*\)$/\1/p')

echo "$BUILD_NUMBER"
