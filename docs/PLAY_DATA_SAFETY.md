# Google Play — Data Safety mapping

This is a **starting point** for filling out the Play Console **Data Safety**
form, derived from what the app actually does in code. The Data Safety answers
**must match** `PRIVACY_POLICY.md`. Review with the same care as the policy
before submitting — this is guidance, not legal advice.

## Data the app handles

| Data | Collected? | Shared? | Purpose | Required? | Notes |
|------|-----------|---------|---------|-----------|-------|
| **Email address** | Yes | No | Account management, App functionality | Required | Stored by Supabase (auth) |
| **Name** | Yes | No | Account management | Required | Stored in Supabase auth metadata |
| **Precise location** | Yes | See note | App functionality | Optional | Sent to Google Maps/Places/Directions and Open Charge Map to return nearby/route results |
| **Other user-generated content** (station reports & notes) | Yes | No | App functionality | Optional | "App activity" category; stored in Supabase |

"Collected" = data leaves the device. "Shared" = transferred to a third party
that is **not** acting as your service provider.

### The location "shared" call

Location coordinates are sent to Google and Open Charge Map to fetch results.
- If you treat Google/Open Charge Map as **service providers acting on your
  behalf**, location is *collected* but not *shared*.
- If you treat them as independent third parties, mark location as **shared**.

When unsure, **err toward disclosure** (mark shared = Yes). Whatever you choose,
name these processors in the privacy policy (already done in `PRIVACY_POLICY.md`
§4).

### Data the app does NOT collect

Password (handled/hashed by the auth provider, never stored by us), contacts,
photos, microphone, advertising ID, device identifiers for tracking, analytics.
Favorites are stored **only on the device** and are not "collected".

## Security section answers

- **Is data encrypted in transit?** Yes (HTTPS/TLS to Supabase, Google, OCM).
- **Can users request data deletion?** Yes — in-app (**Settings → Delete
  Account**) and via the deletion contact in the privacy policy.
- **Committed to follow the Play Families Policy?** Only if you target children
  (this app is not directed at children).

## Also required to publish

1. A **privacy policy URL** — host `PRIVACY_POLICY.md` at a public link and add
   it in Play Console.
2. An **account-deletion URL** — a web page/form (or clear email instructions)
   where users can request deletion, per Play's account-deletion requirement.
3. Keep the Data Safety answers **consistent with the privacy policy** — Google
   checks for mismatches.
