# Apna Charge 🚗⚡

A **Flutter-based** EV charging station finder app that helps users locate **electric vehicle (EV) charging stations**, **plan routes**, and **get real-time directions** to stations.  
Users can **sign up/login** securely using **Supabase authentication** and search for stations with **Google Places API**.  

---

## 📌 **Features**

✔ **User Authentication with Supabase** – Secure login and registration.  
✔ **EV Charging Station Locator** – Fetches real-time station locations via Google Places API.  
✔ **Custom Markers & Interactive Map** – Tapping a marker opens a **bottom sheet** with details.  
✔ **Search Functionality** – Users can find stations by name or location.  
✔ **Smart Route Planner** – Optimizes trips with charging stops for EV range management.  
✔ **Optimized UI/UX** – Fully refined interface for smooth navigation.  

---

## 🛠️ **Built With**
- **Flutter** – UI development framework
- **Google Maps Flutter** – Map integration
- **Google Places API** – Fetching EV charging station data
- **Location** – Getting user’s current location
- **Supabase** – Authentication & backend services

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

Before running the app, configure Google Maps API and Supabase credentials.

🔹 **Google Places API Key Setup**:

  📌 For Android
  
  Open android/app/src/main/AndroidManifest.xml and add:
  ```bash
  <meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY" />
  ```
  📌 For iOS

  Open ios/Runner/Info.plist and add:

  ```bash
  <key>GMSApiKey</key>
<string>YOUR_GOOGLE_MAPS_API_KEY</string>

  ```

🔹 **Supabase Configuration**:

  Create lib/constants.dart and add:
  ```bash
  const String supabaseUrl = "YOUR_SUPABASE_URL";
  const String supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY";
  ```

  Import this into main.dart for initializing Supabase:
  ```bash
  import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'constants.dart'; // Import Supabase keys
import 'login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  runApp(const MyApp());
}
  ```

⚡ **Usage**

  **Run the App**:

  Execute the following command:
  ```bash
  flutter run
  ```


🤝  **Contributing**

Contributions are welcome! If you have suggestions or improvements, please open an issue or submit a pull request.

## License

Distributed under the MIT License. See [License](https://choosealicense.com/licenses/mit/) for details.

