# Google Play Privacy Release Checklist

This checklist applies to ML Leaf version 1.0.0 as currently implemented in
this repository. It is a release aid, not legal advice. Re-audit the release
artifact and every included SDK before each Play submission.

## Source Audit

- The release Android manifest requests no dangerous or sensitive permissions.
- The release Android manifest does not request `INTERNET`.
- The app has no account, sign-in, advertising, analytics, crash reporting, or
  network client dependency.
- The app keeps learner state locally: lesson completion, bookmarks, quiz
  attempts and scores, interview completion, and preferences.
- Interview response text is in-memory session state and is not persisted.
- The app does not transmit user data off-device and does not share or sell it.

## Play Console Data Safety Declaration

For this exact release artifact, answer **No** when Play Console asks whether
the app collects or shares user data. Google Play defines collection as
transmitting data off the user's device; locally stored learning state is not
collected under that definition.

Do not use this answer after adding any SDK, permission, account, telemetry,
advertising, cloud sync, API client, or other behavior that sends data off the
device. Third-party SDK collection must also be declared.

## Privacy Policy Requirements

Before publishing:

1. Keep the support email in `lib/core/constants/app_info.dart` as a real,
   monitored developer contact address.
2. Publish the in-app policy text from `lib/features/settings/privacy_screen.dart`
   at a stable, publicly accessible HTTPS URL. The page must identify ML Leaf
   or its Play Console developer entity.
3. Add that active URL to the Privacy policy field in Play Console and keep the
   hosted text, in-app text, and Data safety declaration consistent.
4. Confirm the final application ID is not `com.example.mlleaf`; it is a
   development placeholder and must be replaced before a Play release.
5. Complete the rest of Play Console's App content declarations, including ads,
   target audience and content, and content rating, based on the final release.

## User Controls

The app provides Settings > Reset study data to clear local learner data.
Because version 1.0.0 has no account or server-side user data, there is no
separate account-deletion or server-data-deletion request flow.
