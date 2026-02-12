#!/bin/bash

# Script to get release notes for a given version
# Usage: ./scripts/get-release-notes.sh [VERSION]

VERSION=${1:-${VERSION:-"1.0.0"}}
RELEASE_NOTES_DIR="release-notes"
RELEASE_NOTES_FILE="${RELEASE_NOTES_DIR}/${VERSION}.txt"
DEFAULT_NOTES_FILE="${RELEASE_NOTES_DIR}/default.txt"

# Create release-notes directory if it doesn't exist
mkdir -p "${RELEASE_NOTES_DIR}"

# Create default.txt if it doesn't exist
if [ ! -f "${DEFAULT_NOTES_FILE}" ]; then
  echo "Thanks for using OneTwoTrail! This release brings bug fixes and improvements to help you tailor travel to your desires." > "${DEFAULT_NOTES_FILE}"
fi

# Check if version-specific release notes exist
if [ -f "${RELEASE_NOTES_FILE}" ]; then
  cat "${RELEASE_NOTES_FILE}"
elif [ -f "${DEFAULT_NOTES_FILE}" ]; then
  cat "${DEFAULT_NOTES_FILE}"
else
  echo "Error: No release notes found for version ${VERSION} and no default.txt exists" >&2
  exit 1
fi
