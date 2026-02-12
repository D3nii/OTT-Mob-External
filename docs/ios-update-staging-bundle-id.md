# iOS Update Staging Bundle ID

## Problem Statement

Currently, iOS builds for staging are using the same bundle ID (`com.onetwotrail`) as production builds, while Android staging builds correctly use `com.onetwotrail.staging`. This creates potential conflicts and inconsistency between platforms.

## Current State

### iOS Configuration
- **All environments** (development, staging, production) use: `com.onetwotrail`
- Build configurations exist for staging: `Debug-staging`, `Release-staging`, `Profile-staging`
- Separate Pods configurations exist for staging environments

### Android Configuration
- **Staging** uses: `com.onetwotrail.staging` ✅
- **Production** uses: `com.onetwotrail` ✅

### Environment Configuration
- `environments/staging.env` specifies: `PACKAGE_NAME=com.onetwotrail.staging`

## Implementation Steps

### 1. Backup Current Configuration
```bash
cp ios/Runner.xcodeproj/project.pbxproj ios/Runner.xcodeproj/project.pbxproj.backup
```

### 2. Update iOS Build Configurations
Modify the following staging configurations in `ios/Runner.xcodeproj/project.pbxproj`:

#### Debug-staging Configuration
```diff
- PRODUCT_BUNDLE_IDENTIFIER = com.onetwotrail;
+ PRODUCT_BUNDLE_IDENTIFIER = com.onetwotrail.staging;
```

#### Release-staging Configuration
```diff
- PRODUCT_BUNDLE_IDENTIFIER = com.onetwotrail;
+ PRODUCT_BUNDLE_IDENTIFIER = com.onetwotrail.staging;
```

#### Profile-staging Configuration
```diff
- PRODUCT_BUNDLE_IDENTIFIER = com.onetwotrail;
+ PRODUCT_BUNDLE_IDENTIFIER = com.onetwotrail.staging;
```

### 3. Review Associated Domains (if applicable)
Check `ios/Runner/Runner.entitlements` for any staging-specific domain requirements.

### 4. Check Flutter Code
Search for hardcoded bundle ID references in Dart files and update any platform-specific code that relies on bundle ID.

### 5. Update Fastlane Configuration
Verify `ios/fastlane/Fastfile` handles the staging bundle ID correctly for TestFlight uploads.

### 6. Test Implementation
```bash
# Test staging build
make ios ENV=staging

# Test production build (for comparison)
make ios ENV=production

# Verify both apps can coexist on device
# - Install production build: make ios-deploy ENV=production
# - Install staging build: make ios-deploy ENV=staging
# - Confirm both apps appear separately
```
