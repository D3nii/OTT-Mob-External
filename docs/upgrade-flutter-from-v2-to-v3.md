# Upgrade Flutter from v2 to v3

## Situation

- Current Flutter version: 2.10.5 (using FVM)
- Dart SDK constraint: >=2.7.0 <3.0.0
- No longer receiving security updates or performance improvements
- Codebase lacks null safety
- Using several outdated dependencies
- Targeting iOS 12.0
- Unable to access bug fixes and new features in newer dependency versions
- Missing significant performance improvements available in Flutter 3
- Compatibility issues will increase as Flutter ecosystem evolves
- Will eventually lose support completely as framework advances

## Task

- Upgrade from Flutter 2.10.5 to Flutter 3.x (latest stable)
- Migrate the codebase to null safety
- Update all dependencies to versions compatible with Flutter 3
- Ensure compatibility across all supported platforms
- Maintain app functionality throughout the upgrade process

## Action

### 1. Update Dart SDK Constraint

- In `pubspec.yaml`, update the Dart SDK constraint to match the Flutter version:
  ```yaml
  environment:
    sdk: ">=3.0.0 <4.0.0"  # Use appropriate constraint for latest Flutter version
  ```

### 2. Flutter SDK Upgrade

- Pin Flutter version using FVM configuration:
  - Create or update the `.fvmrc` file in the project root:
    ```json
    {
      "flutterSdkVersion": "3.29.2"
    }
    ```
  - Run FVM install to ensure the pinned version is available:
    ```bash
    fvm install
    ```
- Verify Flutter setup:
  ```bash
  fvm flutter --version  # Verify pinned version
  fvm flutter pub outdated
  fvm flutter doctor -v
  ```
- Check official Flutter release notes to understand breaking changes in the pinned version: https://docs.flutter.dev/release/release-notes

### 3. Dependency Updates

- Update core Flutter dependencies in `pubspec.yaml`:
  ```yaml
  dependencies:
    flutter:
      sdk: "flutter"
    flutter_localizations:
      sdk: "flutter"
  ```

- You can use Flutter commands to update dependencies:
  ```bash
  # Check for outdated packages
  fvm flutter pub outdated

  # Update all dependencies to their latest compatible versions
  fvm flutter pub upgrade

  # Update all dependencies including those with breaking changes
  fvm flutter pub upgrade --major-versions
  ```

- For each dependency update:
  1. Update version in pubspec.yaml
  2. Run `fvm flutter pub get`

- iOS-specific updates:
  - Update Podfile:
    ```ruby
    platform :ios, '12.0'  # Verify minimum iOS version
    ```
  - Run pod updates:
    ```bash
    cd ios
    pod deintegrate
    pod cache clean --all
    pod install
    ```
  - Review iOS permissions in Info.plist
  - Review and update Facebook SDK integration:
    - Verify FacebookAppID in Info.plist
    - Check FacebookClientToken
    - Update LSApplicationQueriesSchemes

- Android-specific updates:
  - **Modernize Gradle Setup:** Update the Android Gradle configuration to align with modern practices. This involves:
    - Migrating `settings.gradle` to Kotlin DSL (`settings.gradle.kts`) and using `pluginManagement`.
    - Updating the Gradle Wrapper (`gradle/wrapper/gradle-wrapper.properties`) to a version compatible with the chosen Android Gradle Plugin (AGP) version (e.g., Gradle 8.x for AGP 8.x).
    - Removing the `buildscript` block from the top-level `android/build.gradle`.
    - Ensuring `google()` and `mavenCentral()` are used in relevant `repositories` blocks.
  - **Configure AGP, Kotlin, and JDK:** Set compatible versions for AGP and Kotlin (e.g., in `settings.gradle.kts`). Ensure Gradle uses the required Java version (e.g., JDK 17 for AGP 8.x) by configuring `JAVA_HOME` or `org.gradle.java.home`.
  - **Update App-Level `build.gradle`:** Modify `android/app/build.gradle` to:
    - Add the `namespace`.
    - Use `flutter.` properties for SDK versions where possible (e.g., `compileSdkVersion flutter.compileSdkVersion`).
    - Set appropriate Java language compatibility (e.g., Java 11).
    - Apply plugins declaratively (if migrating from older Groovy format).
    - Remove obsolete settings (e.g., `useProguard`, explicit `kotlin-stdlib`).

### 4. Fix Compilation Errors

#### 4.1 Apply Automated Fixes

- Note: The `dart migrate` tool is no longer available in Dart 3.7.2 and newer versions
- Use `dart fix` to automate many migration tasks:
  1. Update the SDK constraints in `pubspec.yaml` to `">=2.12.0 <4.0.0"` as an intermediate step
  2. Run `fvm flutter pub get` to update dependencies
  3. Run `fvm dart fix --dry-run` to see what changes would be made
  4. Run `fvm dart fix --apply` to automatically apply the suggested fixes
  5. This will automatically fix many common issues related to null safety and API changes
- After applying automatic fixes:
  1. Run `fvm flutter analyze` to identify remaining null safety issues
  2. Address the remaining issues manually using the analyzer errors as a guide

#### 4.2 Address Null Safety Issues in Model Classes

- Fix model classes first as they form the foundation of the app
- Common issues to address:
  - Non-nullable fields that aren't initialized
  - Parameters without default values
  - Use the `required` keyword for constructor parameters instead of `@required` annotation
  - Add proper initialization for non-nullable instance fields

#### 4.3 Fix Widget-related Null Safety Issues

- Update widget constructors to use the `required` keyword
- Fix deprecated API usage in Flutter 3
- Address null-aware operator issues where they're no longer needed

#### 4.4 Update API Integration Points

- Fix response handling to properly handle nullable types
- Update service classes to initialize non-nullable fields
- Use the `!` operator only when you're absolutely certain a value isn't null

#### 4.5 Address Specific High-Impact Issues

- Fix the `initialData` missing required arguments in `lib/main.dart`
- Update the `flutter_slidable` integration in `lib/v2/widget/three_squares.dart`
- Fix any missing dependencies like `functional_widget_annotation`
- Address deprecated method calls and API changes in Flutter 3
- Check for platform-specific issues in iOS and Android code

#### 4.6 Address Common Flutter 3 Breaking Changes

- Update to new Material 3 components where applicable
- Fix changes to navigation API (Navigator 2.0)
- Update theme-related code for ThemeData changes
- Address changes in ScrollBehavior and physics

#### 4.7 Final Verification

- Run a full test suite across all platforms
- Perform a comprehensive UI review
- Check app performance metrics
- Verify all third-party integrations are working
- Run `fvm flutter analyze` again to ensure no issues remain

## Success Criteria

- All tests pass on all target platforms
- No visual regressions in UI components
- Improved app performance metrics
- Fully null-safe codebase
- Updated dependencies to latest compatible versions
- Modern Flutter patterns implemented

## Potential Challenges and Mitigations

- **Null Safety Issues**:
  - *Challenge*: Many parts of the codebase may need careful review during the null safety migration.
  - *Mitigation*: Use the migration tool first, then methodically address each file with test coverage.

- **Third-party Plugins**:
  - *Challenge*: Some plugins may not have Flutter 3 compatible versions.
  - *Mitigation*: Identify alternatives or consider forking and updating critical plugins.

- **Breaking API Changes**:
  - *Challenge*: Flutter 3 introduces several breaking changes in the widget API.
  - *Mitigation*: Review the breaking changes documentation and update code accordingly.

- **Platform-specific Issues**:
  - *Challenge*: iOS and Android specific code may need updates.
  - *Mitigation*: Test thoroughly on each platform and address issues as they arise.

## Resources

- [Flutter 3.0 Release Notes](https://docs.flutter.dev/release/release-notes/release-notes-3.0.0)
- [Latest Flutter Release Notes](https://docs.flutter.dev/release/release-notes)
- [Migrating to Flutter 3](https://docs.flutter.dev/release/breaking-changes)
- [Dart Null Safety Migration Guide](https://dart.dev/null-safety/migration-guide)
- [Flutter Upgrade Command Documentation](https://docs.flutter.dev/release/upgrade)
