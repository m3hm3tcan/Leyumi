# Leyumi Google Play release checklist

## Required before the first production upload

- Publish `docs/PRIVACY_POLICY.md` at a public HTTPS URL.
- Add the same URL to Google Play Console's Privacy policy field.
- Complete the Data safety form. For the current offline build, user-entered care data stays on-device and is not collected by the developer.
- Confirm every dependency's data behavior before answering the Data safety form.
- Create the upload keystore and copy `android/key.properties.example` to `android/key.properties` with real values.
- Back up the upload keystore and its passwords outside the repository.
- Enable Play App Signing in Google Play Console.
- Increment `version` and build number in `pubspec.yaml` for every upload.
- Build and upload an Android App Bundle (`.aab`), not a debug APK.
- Run internal testing on at least one Android 15 device and one older supported Android device.

## Product checks

- Verify onboarding, child creation, feeding, diaper, growth, care calendar, milk inventory and PDF sharing.
- Verify EN, TR and HU layouts with large system text.
- Verify dark mode.
- Verify notification permission denial does not break feeding sessions.
- Verify Reset Leyumi deletes every record and returns to onboarding.
- Clearly label cloud backup and smart reminders as Coming soon.
- Do not activate premium sales until store purchase and restore flows are implemented and verified.
