ENV := $(shell [[ -n $$ENV ]] && echo $$ENV || echo development)

include environments/$(ENV).env
export

ifneq ($(ENV),production)
	KEYSTORE_ALIAS := $(shell egrep 'keyAlias' android/key.properties | sed 's/.*=//')
	KEYSTORE_PASSWORD := $(shell egrep 'storePassword' android/key.properties | sed 's/.*=//')
	KEYSTORE_PATH := android/app/$(shell egrep 'storeFile' android/key.properties | sed 's/.*=//')
endif

FASTLANE_AUTO_PUBLISH := $(shell echo $$FASTLANE_AUTO_PUBLISH || echo false)

FLUTTER_VERSION := 3.29.2
FLUTTER := fvm flutter

define FLUTTER_BUILD_OPTIONS
	--dart-define-from-file=dart-definitions/$(ENV).json \
	--flavor $(ENV) \
	--obfuscate \
	--split-debug-info build/symbols
endef

define FLUTTER_RUN_OPTIONS
	--dart-define-from-file=dart-definitions/$(ENV).json \
	--flavor $(ENV) \
	$(if $(DEVICE),-d $(DEVICE),)
endef

.fvm:
	fvm install $(FLUTTER_VERSION)
	fvm use $(FLUTTER_VERSION)

android: .fvm dart-definitions
	@$(FLUTTER) build appbundle $(FLUTTER_BUILD_OPTIONS)
.PHONY: android

android-fastlane:
	@BUILD_NUMBER="$$(./scripts/get-build-number.sh)" \
	&& VERSION="$$(./scripts/get-version.sh)" \
	&& cd android \
	&& \
		BUILD_NUMBER="$$BUILD_NUMBER" \
		ENV="$(ENV)" \
		FASTLANE_ANDROID_GOOGLE_PLAY_JSON_KEY_PATH="$(FASTLANE_ANDROID_GOOGLE_PLAY_JSON_KEY_PATH)" \
		FASTLANE_AUTO_PUBLISH=$(FASTLANE_AUTO_PUBLISH) \
		PACKAGE_NAME="$(PACKAGE_NAME)" \
		VERSION="$$VERSION" \
		fastlane deploy
.PHONY: android-fastlane

android-fastlane-validate:
	@cd android \
		&& fastlane run validate_play_store_json_key \
			json_key:"../$(FASTLANE_ANDROID_GOOGLE_PLAY_JSON_KEY_PATH)"
.PHONY: android-fastlane-validate

android-clean: .fvm
	@cd android && ./gradlew clean
	@$(FLUTTER) clean
.PHONY: android-clean

app-links-refresh:
	@adb shell am compat enable 175408749 $(PACKAGE_NAME)
	@adb shell pm set-app-links --package $(PACKAGE_NAME) 0 all
	@adb shell pm verify-app-links --re-verify $(PACKAGE_NAME)
.PHONY: app-links-refresh

app-links-get:
	@adb shell pm get-app-links $(PACKAGE_NAME)
.PHONY: app-links-get

clean:
	@git clean -dfX
.PHONY: clean

dart-definitions:
	@mkdir -p dart-definitions
	@echo '{' > dart-definitions/$(ENV).json
	@echo '  "API_URL": "$(API_URL)",' >> dart-definitions/$(ENV).json
	@echo '  "DATADOG_APPLICATION_ID": "$(DATADOG_APPLICATION_ID)",' >> dart-definitions/$(ENV).json
	@echo '  "DATADOG_CLIENT_TOKEN": "$(DATADOG_CLIENT_TOKEN)",' >> dart-definitions/$(ENV).json
	@echo '  "GOOGLE_MAPS_API_KEY": "$(GOOGLE_MAPS_API_KEY)"' >> dart-definitions/$(ENV).json
	@echo '}' >> dart-definitions/$(ENV).json
.PHONY: dart-definitions

keystore-generate:
	@keytool -genkey -v -keystore \
		upload-keystore.jks \
		-keyalg RSA \
		-keysize 2048 \
		-validity 10000 \
		-alias upload
.PHONY: keystore-generate

keystore-hash:
ifneq ($(KEYSTORE_FINGERPRINT_SHA1),)
	@echo $(KEYSTORE_FINGERPRINT_SHA1) | xxd -r -p | openssl base64
else
	@keytool -exportcert \
		-alias $(KEYSTORE_ALIAS) \
		-keystore $(KEYSTORE_PATH) \
		-storepass $(KEYSTORE_PASSWORD) \
		| openssl sha1 -binary \
		| openssl base64
endif
.PHONY: keystore-hash

keystore-fingerprints:
ifneq ($(KEYSTORE_FINGERPRINT_SHA256),)
	@echo $(KEYSTORE_FINGERPRINT_SHA256)
else
	@keytool -list \
		-v \
		-keystore $(KEYSTORE_PATH) \
		-storepass $(KEYSTORE_PASSWORD) \
		| egrep "(SHA256:|SHA1:)" \
		| cut -d ' ' -f 3
endif
.PHONY: keystore-fingerprints

keystore-pem:
	@keytool \
		-export \
		-rfc \
		-keystore upload-keystore.jks \
		-alias upload \
		-file upload-certificate.pem
.PHONY: keystore-pem

format: .fvm
	@$(FLUTTER) format lib
.PHONY: format

flutter-upgrade:
	@echo "Determining latest stable Flutter version..." \
	&& LATEST_STABLE=$$(fvm install stable >/dev/null 2>&1 && fvm use stable >/dev/null 2>&1 && fvm flutter --version | head -n 1 | cut -d ' ' -f 2); \
	if [ -z "$$LATEST_STABLE" ]; then \
	  echo "Error: Could not determine latest stable Flutter version." >&2; \
	  exit 1; \
	fi \
	&& echo "Latest stable version identified as: $$LATEST_STABLE" \
	&& echo "Pinning project to version $$LATEST_STABLE in .fvmrc..." \
	&& echo "{\"flutterSdkVersion\": \"$$LATEST_STABLE\"}" > .fvmrc \
	&& echo "Ensuring pinned version $$LATEST_STABLE is installed locally..." \
	&& fvm install \
	&& echo "Upgrading dependencies to latest compatible versions..." \
	$(FLUTTER) pub upgrade
.PHONY: flutter-upgrade

flutter-verify:
	@echo "Verifying Flutter setup..."
	@$(FLUTTER) --version
	@echo "Checking outdated packages..."
	@$(FLUTTER) pub outdated
	@echo "Running Flutter doctor..."
	@$(FLUTTER) doctor -v
.PHONY: flutter-verify

ios: .fvm dart-definitions
	@$(FLUTTER) build ipa $(FLUTTER_BUILD_OPTIONS)
.PHONY: ios

ios-clean: .fvm
	cd ios \
		&& pod deintegrate \
		&& pod cache clean --all \
		&& rm -rf Pods
	@$(FLUTTER) clean
.PHONY: ios-clean

ios-deploy:
	@open build/ios/archive/Runner.xcarchive
.PHONY: ios-deploy

ios-fastlane:
	@VERSION="$$(./scripts/get-version.sh)" \
	&& RELEASE_NOTES="$$(./scripts/get-release-notes.sh $$VERSION)" \
	&& cd ios \
	&& \
		ENV="$(ENV)" \
		FASTLANE_AUTO_PUBLISH=$(FASTLANE_AUTO_PUBLISH) \
		FASTLANE_IOS_APPLE_ID="$(FASTLANE_IOS_APPLE_ID)" \
		FASTLANE_IOS_ITC_TEAM_ID="$(FASTLANE_IOS_ITC_TEAM_ID)" \
		FASTLANE_IOS_TEAM_ID="$(FASTLANE_IOS_TEAM_ID)" \
		PACKAGE_NAME="$(PACKAGE_NAME)" \
		RELEASE_NOTES="$$RELEASE_NOTES" \
		VERSION="$$VERSION" \
		fastlane deploy
.PHONY: ios-fastlane

ios-install:
	@$(FLUTTER) pub get
	@cd ios && pod install
.PHONY: ios-install

ios-upgrade: ios-clean
	@rm -f ios/Podfile.lock
	@$(FLUTTER) pub get
	@$(FLUTTER) precache --ios
	@cd ios && pod install --repo-update
.PHONY: ios-upgrade

ios-update:
	@cd ios && pod update --clean-install
.PHONY: ios-update

l10n: .fvm
	@$(FLUTTER) gen-l10n
.PHONY: l10n

run: .fvm dart-definitions
	@$(FLUTTER) run $(FLUTTER_RUN_OPTIONS)
.PHONY: run

test: .fvm
	@$(FLUTTER) test
.PHONY: test

xcode:
	@open ios/Runner.xcworkspace
.PHONY: xcode
