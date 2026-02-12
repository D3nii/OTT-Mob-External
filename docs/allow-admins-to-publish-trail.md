# Allow Admins to Publish Trail

## Why

To enable trail discovery and sharing within the platform, admin users need the ability to mark trails as public, making them discoverable by other users in the trail discovery features. This feature will enable content curation by admin users, allow for featured trail content in discovery sections, provide a mechanism for promoting high-quality trails to the broader user base, and support future marketplace or trail sharing features.

## Current State

All trails in the OneTrail mobile application are currently private by default, meaning they can only be accessed by their creator and collaborators. The trail editing system allows users to modify trail name, description, and collaborators through the EditTrailDialogForm, but there is no mechanism for changing trail visibility. The application has separate routing for private trails (/private-trail) and public trails (/public-trail), suggesting the infrastructure exists but lacks admin controls. User permissions are currently limited to basic authentication checks without role-based access control for administrative functions.

## Expected State

Admin users will have access to a toggle control within the trail editing interface that allows them to mark trails as public or private. The Trail model will include an isPublic property that determines discoverability, with public trails appearing in discovery features while private trails remain restricted to creators and collaborators. The user permission system will differentiate between regular users and admin users, with only admins seeing and being able to use the public toggle. API endpoints will support updating trail visibility status, and the system will provide appropriate feedback when trails are published or made private.

## Implementation

### Layer 1: Data Model Updates

Extend the existing Trail model with isPublic boolean property, following the same pattern as other Trail properties like status and collaborators. Update Trail.fromJson to handle the 'is_public' field from API responses, defaulting to false for backward compatibility.

#### Test Scenarios

**Trail.isPublic**

- **with public trail**: Trail.isPublic should return true
- **with private trail**: Trail.isPublic should return false (default)

**Trail.fromJson**

- **with isPublic field**: sets `isPublic` from provided data
- **with missing isPublic field**: defaults `isPublic` to false

### Layer 2: Admin Gating via Existing API Context

Use the existing `ApplicationApi` context and follow the `runBasedOnUser` pattern. Determine admin rights from the session JSON returned by sign-in/up responses (the `is_admin` field), without modifying the `User` model or introducing a new permissions helper. Expose a simple helper: `bool isAdminUser(BuildContext context)` that returns true/false for admin gating in UI and actions.

- Implementation notes:
  - Read `is_admin` from the sign-in/sign-up response and persist it alongside the existing API context (e.g., via `ApplicationApi.updateContext(...)` and stored preferences), or expose a simple `ApplicationApi.isAdmin` getter that reads the persisted flag consumed by `isAdminUser(context)`.
  - Do not add fields to `User` and do not create a standalone permission service/helper.

### Layer 3: UI Toggle Component

Create LabeledToggle as reusable component accepting text label and value parameters, following the existing AddToggleButton and OwnCheckBox patterns. Use Switch widget with tealish color consistent with app styling. Include disabled state handling for save operations. Structure as Row with provided text label and toggle, similar to existing form controls in EditTrailDialogForm.

#### Test Scenarios

**LabeledToggle.build**

- **with enabled state**: renders switch and label
- **with disabled state**: is not interactive during save

**LabeledToggle.onChanged**

- **with toggle interaction**: emits change when toggled

### Layer 4: API Integration

Add dedicated publishTrail and unpublishTrail methods to ApplicationApi following the existing deleteTrail and updateTrail patterns. Use HTTP PATCH requests to "trails/{trailId}/publish" and "trails/{trailId}/unpublish" endpoints for semantic clarity. Integrate new methods into TrailService with publishTrail and unpublishTrail wrapper methods that handle stream updates, following the existing deleteTrail pattern for consistency.

### Layer 5: Localization Support

Add localization entries to app_en.arb for trailIsPublicText, trailPublishedText, and trailUnpublishedText, following the existing pattern of other UI text keys. Use AppLocalizations.of(context) pattern throughout UI components, with fallback text for missing translations.

### Layer 6: Edit Form Integration

Extend `EditTrailDialogFormModel` with `isPublic` property and getter/setter following the existing controller pattern. Integrate `LabeledToggle` into `EditTrailDialogForm` after `TextAreaEditTrail`, showing it conditionally when `isAdminUser(context)` is true. Call dedicated `publishTrail` or `unpublishTrail` methods from `TrailService` immediately when toggle changes, separate from the standard trail update flow. Show loading state on the toggle during the API call and provide immediate feedback via SnackBar notifications using existing styling. Choose message text based on public status change: `trailPublishedText` when becoming public, `trailUnpublishedText` when becoming private, or existing `changesSavedText` when no public status change is involved.
