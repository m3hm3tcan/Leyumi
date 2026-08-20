# Leyumi Google Play release checklist

## Required before the first production upload

- Keep `docs/PRIVACY_POLICY.md` published at `https://leyumi-privacy-policy.leyumistudio.workers.dev/` and update the live page whenever this file changes.
- Add the same URL to Google Play Console's Privacy policy field.
- Complete the Data safety form. For the current offline build, user-entered care data stays on-device and is not collected by the developer.
- Complete Google Play's Health apps declaration according to the actual growth, feeding, medicine and vaccine tracking features. Declare at least `Disease Prevention and Public Health` for vaccine tracking and `Medication and Treatment Management` for medicine reminders; evaluate `Nutrition and Weight Management` against the final feeding and growth feature set. Do not select `My app doesn't provide any health features` while these features are present.
- Include this meaning in every localized store description: Leyumi is not a medical device or healthcare service; it does not diagnose, treat, cure or prevent any medical condition, and users should consult a qualified healthcare professional for medical advice, diagnosis or treatment.
- Confirm every dependency's data behavior before answering the Data safety form.
- Create the upload keystore and copy `android/key.properties.example` to `android/key.properties` with real values.
- Back up the upload keystore and its passwords outside the repository.
- Enable Play App Signing in Google Play Console.
- Increment `version` and build number in `pubspec.yaml` for every upload.
- Build and upload an Android App Bundle (`.aab`), not a debug APK.
- Run internal testing on at least one Android 16 device and one older supported Android device.
- Confirm the Play Console device catalog reflects the Android 7.0 (API 24) minimum supported version.

## Product checks

- Verify onboarding, child creation, feeding, diaper, growth, care calendar, milk inventory and PDF sharing.
- Verify EN, TR and HU layouts with large system text.
- Verify dark mode.
- Verify notification permission denial does not break feeding sessions.
- Verify Reset Leyumi deletes every record and returns to onboarding.
- Clearly label cloud backup and smart reminders as Coming soon.
- Do not activate premium sales until store purchase and restore flows are implemented and verified.
- Do not advertise premium in the store listing while its purchase flow is unavailable.
