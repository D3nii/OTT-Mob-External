# Fastlane Release and Deploy Application

This document outlines the implementation plan for deploying app builds using Fastlane for both iOS (AppStore Connect) and Android (Google Play Store) platforms.

## Overview

Fastlane is an automation tool that streamlines the deployment process for mobile applications. This plan integrates Fastlane with the existing Flutter build system to provide automated deployment capabilities with environment-based lane selection and automatic release notes lookup.

Both iOS and Android platforms automatically discover their package names from environment variables:

- **iOS**: Uses `PACKAGE_NAME` environment variable as the bundle identifier
- **Android**: Uses `PACKAGE_NAME` environment variable as the package name

The
`PACKAGE_NAME` variable is defined in each environment file (development.env, staging.env, production.env) with appropriate values for each deployment target.

## Prerequisites

### General Requirements

- Homebrew (for installing Fastlane)
- Existing Flutter development environment with FVM
- Valid developer accounts for both Apple App Store and Google Play Store

### Install Fastlane via Homebrew

Install Fastlane using Homebrew:

```bash
brew install fastlane
```

This approach simplifies the installation process by eliminating the need for Ruby gem management and Bundler.

## Implementation Plan

### Phase 1: iOS Configuration

#### 1.1 Initialize Fastlane for iOS

Initialize Fastlane in the iOS directory:

```bash
cd ios && fastlane init
```

Since Fastlane is installed via Homebrew, no Gemfile is needed and you can run Fastlane commands directly.

#### 1.2 Automatic Version Detection

Create the version extraction script (`scripts/get-version.sh`):

```bash
#!/bin/bash

# Script to extract version from pubspec.yaml
# Usage: ./scripts/get-version.sh

PUBSPEC_FILE="pubspec.yaml"

if [ ! -f "$PUBSPEC_FILE" ]; then
    echo "Error: pubspec.yaml not found" >&2
    exit 1
fi

# Extract version line and get the semantic version part (before the +)
VERSION=$(grep "^version:" "$PUBSPEC_FILE" | sed 's/version: *//' | sed 's/+.*//')

if [ -z "$VERSION" ]; then
    echo "Error: Could not extract version from pubspec.yaml" >&2
    exit 1
fi

echo "$VERSION"
```

Make the script executable:

```bash
chmod +x scripts/get-version.sh
```

This script automatically extracts the semantic version from
`pubspec.yaml`. For example, if `pubspec.yaml` contains
`version: 1.9.0+93`, the script returns `1.9.0`.

#### 1.3 Release Notes Setup

Create the shared release notes script (`scripts/get-release-notes.sh`):

```bash
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
```

Make the script executable:

```bash
chmod +x scripts/get-release-notes.sh
```

For each version, create a corresponding release notes file:

```bash
echo "New features and enhancements for version 1.2.0" > release-notes/1.2.0.txt
```

#### 1.4 iOS Fastfile Structure

Create `ios/fastlane/Fastfile` with environment-based lane selection:

```ruby
default_platform(:ios)

platform :ios do
  desc "Deploy based on environment"
  lane :deploy do
    case ENV['ENV']
    when 'staging'
      staging
    when 'production'
      production
    else
      UI.user_error!("Unknown environment: #{ENV['ENV']}. Use 'staging' or 'production'")
    end
  end

  desc "Upload to TestFlight (staging)"
  lane :staging do
    upload_to_testflight(
      ipa: "../build/ios/ipa/onetwotrail.ipa",
      changelog: ENV['RELEASE_NOTES'] || "Bug fixes and improvements",
      distribute_external: ENV['FASTLANE_AUTO_PUBLISH'] == 'true',
      groups: ENV['FASTLANE_AUTO_PUBLISH'] == 'true' ? ["External Testers"] : nil,
      notify_external_testers: ENV['FASTLANE_AUTO_PUBLISH'] == 'true'
    )
  end

  desc "Upload to App Store (production)"
  lane :production do
    upload_to_app_store(
      ipa: "../build/ios/ipa/onetwotrail.ipa",
      force: true,
      reject_if_possible: true,
      changelog: ENV['RELEASE_NOTES'] || "Bug fixes and improvements",
      automatic_release: ENV['FASTLANE_AUTO_PUBLISH'] == 'true',
      submit_for_review: ENV['FASTLANE_AUTO_PUBLISH'] == 'true',
      submission_information: {
        add_id_info_limits_tracking: true,
        add_id_info_serves_ads: false,
        add_id_info_tracks_action: true,
        add_id_info_tracks_install: true,
        add_id_info_uses_idfa: true,
        content_rights_has_rights: true,
        content_rights_contains_third_party_content: true,
        export_compliance_platform: 'ios',
        export_compliance_compliance_required: false,
        export_compliance_encryption_updated: false,
        export_compliance_app_type: nil,
        export_compliance_uses_encryption: false,
        export_compliance_is_exempt: false,
        export_compliance_contains_third_party_cryptography: false,
        export_compliance_contains_proprietary_cryptography: false,
        export_compliance_available_on_french_store: false
      }
    )
  end
end
```

#### 1.5 iOS Environment Configuration

Create `ios/fastlane/Appfile`:

```ruby
app_identifier(ENV['PACKAGE_NAME'])
apple_id(ENV['FASTLANE_IOS_APPLE_ID'])
itc_team_id(ENV['FASTLANE_IOS_ITC_TEAM_ID'])
team_id(ENV['FASTLANE_IOS_TEAM_ID'])
```

#### 1.6 iOS Makefile Integration

Add iOS Fastlane target to the existing Makefile:

```makefile
# iOS Fastlane target
ios-fastlane: ios
	@VERSION="$$(./scripts/get-version.sh)" \
	&& RELEASE_NOTES="$$(./scripts/get-release-notes.sh $$VERSION)" \
	&& cd ios \
	&& \
		VERSION="$$VERSION" \
		FASTLANE_AUTO_PUBLISH=$(FASTLANE_AUTO_PUBLISH) \
		RELEASE_NOTES="$$RELEASE_NOTES" fastlane deploy
.PHONY: ios-fastlane
```

**Usage:**

```bash
make ENV=staging ios-fastlane FASTLANE_AUTO_PUBLISH=false
make ENV=production ios-fastlane FASTLANE_AUTO_PUBLISH=true
```

**Note:** The VERSION is automatically detected from
`pubspec.yaml`. The system extracts the semantic version part (e.g., "1.9.0" from "1.9.0+93") and uses it for release notes lookup and Fastlane deployment.

**Environment Variables:**

- `FASTLANE_IOS_APPLE_ID`: Your Apple ID email
- `FASTLANE_IOS_ITC_TEAM_ID`: App Store Connect team ID
- `FASTLANE_IOS_TEAM_ID`: Apple Developer team ID
- `PACKAGE_NAME`: iOS bundle identifier

### Phase 2: Android Configuration

#### 2.1 Initialize Fastlane for Android

Initialize Fastlane in the Android directory:

```bash
cd android && fastlane init
```

Since Fastlane is installed via Homebrew, no Gemfile is needed and you can run Fastlane commands directly.

#### 2.2 Android Fastfile Structure

Create `android/fastlane/Fastfile`:

```ruby
default_platform(:android)

platform :android do
  desc "Deploy based on environment"
  lane :deploy do
    case ENV['ENV']
    when 'staging'
      staging
    when 'production'
      production
    else
      UI.user_error!("Unknown environment: #{ENV['ENV']}. Use 'staging' or 'production'")
    end
  end

  desc "Upload to internal testing (staging)"
  lane :staging do
    upload_to_play_store(
      track: 'internal',
      aab: "../build/app/outputs/bundle/#{ENV['ENV']}Release/app-#{ENV['ENV']}-release.aab",
      json_key: ENV['FASTLANE_ANDROID_GOOGLE_PLAY_JSON_KEY_PATH'],
      package_name: ENV['PACKAGE_NAME'],
      release_status: ENV['FASTLANE_AUTO_PUBLISH'] == 'true' ? 'completed' : 'draft',
      changelog: ENV['RELEASE_NOTES'] || "Bug fixes and improvements"
    )
  end

  desc "Upload to production"
  lane :production do
    upload_to_play_store(
      track: 'production',
      aab: "../build/app/outputs/bundle/#{ENV['ENV']}Release/app-#{ENV['ENV']}-release.aab",
      json_key: ENV['FASTLANE_ANDROID_GOOGLE_PLAY_JSON_KEY_PATH'],
      package_name: ENV['PACKAGE_NAME'],
      release_status: ENV['FASTLANE_AUTO_PUBLISH'] == 'true' ? 'completed' : 'draft',
      changelog: ENV['RELEASE_NOTES'] || "Bug fixes and improvements"
    )
  end
end
```

#### 2.3 Android Environment Configuration

Create `android/fastlane/Appfile`:

```ruby
json_key_file(ENV['FASTLANE_ANDROID_GOOGLE_PLAY_JSON_KEY_PATH'])
package_name(ENV['PACKAGE_NAME'])
```

#### 2.4 Android Makefile Integration

Add Android Fastlane target to the existing Makefile:

```makefile
# Android Fastlane target
android-fastlane: android
	@VERSION="$$(./scripts/get-version.sh)" \
	&& RELEASE_NOTES="$$(./scripts/get-release-notes.sh $$VERSION)" \
	&& cd android \
	&& \
		VERSION="$$VERSION" \
		FASTLANE_AUTO_PUBLISH=$(FASTLANE_AUTO_PUBLISH) \
		RELEASE_NOTES="$$RELEASE_NOTES" fastlane deploy
.PHONY: android-fastlane
```

**Usage:**

```bash
make ENV=staging android-fastlane FASTLANE_AUTO_PUBLISH=false
make ENV=production android-fastlane FASTLANE_AUTO_PUBLISH=true
```

**Note:** The VERSION is automatically detected from
`pubspec.yaml`. The system extracts the semantic version part (e.g., "1.9.0" from "1.9.0+93") and uses it for release notes lookup and Fastlane deployment.

**Environment Variables:**

-

`FASTLANE_ANDROID_GOOGLE_PLAY_JSON_KEY_PATH`: Path to the service account JSON key
-
`PACKAGE_NAME`: Android package name (automatically read from environment files)
