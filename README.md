# Apna Charge 🚗⚡

A **Flutter-based** EV charging station finder app that helps users locate **electric vehicle (EV) charging stations**, **plan routes**, and **get real-time directions** to stations.  
Users can **sign up/login** securely using **Supabase authentication** and search for stations with **Google Places API**.  

---
![Thumbnail](assets/images/thumbnail.png)

## 📌 **Features**

✔ **User Authentication with Supabase** – Secure login and registration.  
✔ **Real EV Charging Data** – Live station data from the **Open Charge Map** API: operator, connector types, power (kW), operational status and pricing.  
✔ **Custom Markers & Interactive Map** – Tapping a marker opens a **bottom sheet** with real station details.  
✔ **Favorites** – Save stations locally and reopen directions in one tap.  
✔ **Search Functionality** – Find locations via Google Places autocomplete.  
✔ **Smart Route Planner** – Plan trips and surface charging stops along the way.  
✔ **Optimized UI/UX** – Refined interface for smooth navigation.  

---

## 🛠️ **Built With**
- **Flutter** – UI development framework
- **Google Maps Flutter** – Map integration
- **Open Charge Map API** – Real EV charging station data
- **Google Places API** – Location search / autocomplete
- **Location / Geolocator** – Getting the user’s current location
- **Supabase** – Authentication & backend services
- **flutter_dotenv** – Environment-based secret management

---

## 🚀 **Installation**

### 🔹 **Clone the Repository**
```bash
git clone https://github.com/yourusername/ev-charging-station-finder.git
cd ev-charging-station-finder
```

### 🔹 **Clone the Repository**
```bash
flutter pub get
```


## 🔑 Environment Variables

All secrets live in a git-ignored `.env` file (loaded via `flutter_dotenv`).
Never commit real keys.

1. Copy the template:
   ```bash
   cp .env.example .env
   ```
2. Fill in your values in `.env`:
   ```dotenv
   SUPABASE_URL=https://YOUR_PROJECT.supabase.co
   SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
   GOOGLE_MAPS_API_KEY=YOUR_GOOGLE_MAPS_API_KEY
   OPEN_CHARGE_MAP_API_KEY=YOUR_OPEN_CHARGE_MAP_API_KEY   # free: openchargemap.org
   MAPBOX_ACCESS_TOKEN=YOUR_MAPBOX_ACCESS_TOKEN           # optional (future map layer)
   ```
3. The **native Android map** needs the Google key separately in
   `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <meta-data
     android:name="com.google.android.geo.API_KEY"
     android:value="YOUR_GOOGLE_MAPS_API_KEY" />
   ```
   For **iOS**, add it to `ios/Runner/AppDelegate` / `Info.plist` as required by
   `google_maps_flutter`.

> **Note:** Open Charge Map provides the charging-station data and is free — no
> key is strictly required for light usage, but registering for one raises your
> rate limits.

## 🔐 Google Sign-In Setup

The app supports email/password **and** Google sign-in (native ID-token flow via
Supabase). To enable Google sign-in:

1. In **Google Cloud Console → Credentials**, create OAuth 2.0 client IDs:
   - a **Web** client ID (used as the Supabase server client ID on all platforms),
   - an **Android** client ID (register your app's SHA-1 fingerprint),
   - an **iOS** client ID.
2. Put the Web and iOS client IDs in `.env`
   (`GOOGLE_WEB_CLIENT_ID`, `GOOGLE_IOS_CLIENT_ID`).
3. In the **Supabase dashboard → Authentication → Providers → Google**, enable
   Google and add the **Web client ID** under authorized client IDs.
4. **iOS:** add your iOS client ID's reversed form to
   `ios/Runner/Info.plist` as a `CFBundleURLSchemes` entry.
5. **Android:** no client ID is needed in code; just ensure the SHA-1 is
   registered in the Google Cloud project.

The Google button is hidden-safe: if `GOOGLE_WEB_CLIENT_ID` is unset it shows a
clear "not configured" message instead of crashing.

⚡ **Usage**

  **Run the App**:

  Execute the following command:
  ```bash
  flutter run
  ```

## 🗄️ Supabase Setup (community reports)

The "Is it working?" community reliability feature stores crowd-sourced
station reports in Supabase. Apply the database schema once:

- **Dashboard:** open your project → SQL Editor → paste the contents of
  `supabase/migrations/20260723000000_station_reports.sql` → Run.
- **CLI:** `supabase db push`

This creates the `station_reports` table with Row Level Security (each user can
only touch their own report) and a `get_station_status_summary` function that
exposes aggregate counts only. The feature degrades gracefully if the migration
hasn't been applied yet.

**Account deletion (required by Google Play / DPDP / GDPR):** the in-app
"Delete Account" button calls a Supabase Edge Function that removes the auth
user (their reports cascade-delete). Deploy it once:

```bash
supabase functions deploy delete-account
```

## ⚖️ Legal documents

`PRIVACY_POLICY.md` and `TERMS_OF_SERVICE.md` (repo root) are shown in-app under
**Settings → Legal** and should also be hosted at a public URL for the Play
Store listing. Before publishing, **fill in every `[PLACEHOLDER]`** (legal name,
contact email, Grievance Officer, effective date, jurisdiction) and have the
documents reviewed by a legal/privacy professional. They are drafted from
current guidance but are not a substitute for legal advice.


🤝  **Contributing**

Contributions are welcome! If you have suggestions or improvements, please open an issue or submit a pull request.

## License

Distributed under the MIT License. See [License](https://choosealicense.com/licenses/mit/) for details.

