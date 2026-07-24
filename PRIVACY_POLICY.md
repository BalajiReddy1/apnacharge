# Privacy Policy — Apna Charge

**Last updated:** [EFFECTIVE_DATE — e.g. 24 July 2026]

This Privacy Policy explains how **Apna Charge** ("we", "us", "the app"),
operated by **[LEGAL_NAME / DEVELOPER NAME]**, collects, uses, shares and
protects your personal data when you use the Apna Charge mobile application.

We act as the **Data Fiduciary / Data Controller** for the personal data
processed through the app. We are committed to complying with the **Digital
Personal Data Protection Act, 2023 (India)**, the **EU General Data Protection
Regulation (GDPR)**, the **California Consumer Privacy Act (CCPA/CPRA)** and
Google Play's User Data policy.

> **Plain-language summary:** We collect your email, name, and — with your
> permission — your device location so we can show you nearby EV charging
> stations. We store your community "is it working?" reports. We do **not**
> sell your data. You can delete your account and all associated data at any
> time from **Settings → Delete Account**.

---

## 1. Data we collect

| Data | Why we collect it | Where it is stored |
|------|-------------------|--------------------|
| **Email address** | To create and secure your account | Supabase (auth) |
| **Name** | To personalise your account | Supabase (auth metadata) |
| **Password** | To authenticate you (stored hashed, never in plain text) | Supabase (auth) |
| **Precise location (GPS)** | To find charging stations near you and plan routes | Sent to Google & Open Charge Map to fetch results; not stored on our servers |
| **Community reports** ("working / not working") | To show other drivers whether a charger is reliable | Supabase, linked to your account |
| **Favorite stations** | To let you save stations | Stored **only on your device** (not uploaded) |

We collect only what the app needs to function (data minimisation). We do
**not** collect contacts, photos, microphone, or advertising identifiers.

## 2. How we use your data

- Authenticate you and keep your account secure.
- Show EV charging stations near your location and along planned routes.
- Let you submit and view crowd-sourced station reliability reports.
- Respond to your support and privacy requests.

We do **not** use your data for advertising, profiling, or automated
decision-making, and we do **not** sell or "share" your personal data as those
terms are defined under the CCPA/CPRA.

## 3. Legal basis for processing (GDPR / DPDP)

- **Consent** — for accessing your device location and for creating your
  account. You give consent through a clear affirmative action (granting the
  location permission; agreeing to the Terms and this Policy at sign-up).
- **Performance of a contract** — to provide the account and app features you
  request.

You can withdraw consent at any time (see *Your rights*). Withdrawing location
permission is done through your device settings; the app remains usable but
cannot show nearby stations.

## 4. Who we share data with

We use the following third-party processors. Location and search queries are
sent to some of them to return results:

- **Supabase** — authentication and storage of your account and reports.
  <https://supabase.com/privacy>
- **Google** (Maps SDK, Places, Directions) — to render maps, search places,
  and compute routes. Receives location/search queries.
  <https://policies.google.com/privacy>
- **Open Charge Map** — the source of charging-station data. Receives the
  coordinates we query around. <https://openchargemap.org/site/develop/api>

We share data with these providers only to operate the app. We do not sell
data or share it with advertisers or data brokers.

## 5. International data transfers

Our providers (Supabase, Google) may process and store data on servers outside
your country, including outside India and the EU. Where required, transfers are
protected by appropriate safeguards such as standard contractual clauses.

## 6. Data retention

- Account data (email, name) is kept until you delete your account.
- Community reports are kept until you retract them or delete your account.
- Favorites are kept on your device until you remove them or uninstall the app.

When you delete your account, associated server data is deleted (see §8).

## 7. Your rights

Depending on where you live, you have some or all of the following rights:

- **Access** — request a copy of your personal data.
- **Correction** — correct inaccurate data.
- **Erasure / Deletion** — delete your account and associated data.
- **Withdraw consent** — including revoking location permission.
- **Data portability** (GDPR) — receive your data in a portable format.
- **Opt-out of sale/sharing** (CCPA) — not applicable, as we do not sell or
  share your data.
- **Grievance redressal** (DPDP) — escalate concerns to our Grievance Officer.

To exercise any right, use the in-app tools (Settings) or contact us at
**[CONTACT_EMAIL]**. We respond within the timelines required by applicable law.

## 8. Account and data deletion

You can delete your account and all associated data at any time:

- **In-app:** open **Settings → Delete Account** and confirm. This permanently
  deletes your account, and your community reports are removed automatically.
- **Web / email:** send a deletion request to **[CONTACT_EMAIL]** and we will
  process it within 30 days.

Deletion is permanent and cannot be undone. Favorites stored on your device are
removed when you delete your account or uninstall the app.

## 9. Children's data

Apna Charge is not directed at children. Under the DPDP Act, users under 18 are
treated as children and require verifiable parental consent. We do not
knowingly collect data from children without such consent. If you believe a
child has provided us data, contact us and we will delete it.

## 10. Security

- Passwords are hashed by our authentication provider; we never see them.
- Data is transmitted over encrypted connections (HTTPS/TLS).
- Community reports are protected by database Row Level Security, so each user
  can only access their own report rows.

No system is perfectly secure, but we take reasonable technical and
organisational measures to protect your data.

## 11. Changes to this policy

We may update this policy from time to time. Material changes will be notified
in-app or by updating the "Last updated" date above. Continued use after an
update constitutes acceptance of the revised policy.

## 12. Contact & Grievance Officer

**Grievance Officer / Data Protection Contact:** [OFFICER_NAME]
**Email:** [CONTACT_EMAIL]
**Address:** [BUSINESS_ADDRESS]

If you are in the EU/EEA and are unsatisfied with our response, you may lodge a
complaint with your local supervisory authority. If you are in India, you may
escalate to the Data Protection Board of India.
