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


🤝  **Contributing**

Contributions are welcome! If you have suggestions or improvements, please open an issue or submit a pull request.

## License

Distributed under the MIT License. See [License](https://choosealicense.com/licenses/mit/) for details.

