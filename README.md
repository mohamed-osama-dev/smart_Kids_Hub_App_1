# Smart Kids Hub 🌟

**Smart Kids Hub** is a comprehensive platform designed to monitor children's health and growth. It focuses on providing a personalized experience for each child by tracking physical development, generating AI-powered smart nutritional plans, and directly integrating with smart devices like electronic scales.

---

## 🎯 Features

### 1. 🍽️ AI Meal Planning
- Generate customized weekly dietary plans for each child.
- Take into account food allergies and eating preferences.
- Save meals and suggestions for easy reference.
- Full details of recipes and ingredients.

### 2. ⚖️ Growth & Measurements Tracking
- Connect the app to a smart scale via Bluetooth (BLE Scale Integration).
- Read data wirelessly and record it in real-time.
- View charts and continuously monitor the child's growth.

### 3. 🔐 Authentication & Security
- Secure login and data protection.
- Secure storage of sensitive information using `Secure Storage`.

---

## 🛠️ Tech Stack

The application is built using the **Flutter** framework to run on both Android & iOS.

**Key Packages:**
- **State Management:** `Provider` (and `Cubit/Bloc` in certain sections).
- **Networking:** `Dio` for API calls.
- **Local Storage:** `Hive`, `Shared Preferences`, and `Flutter Secure Storage`.
- **Bluetooth:** `flutter_blue_plus` for connecting to the smart scale.

---

## 📂 Project Structure

The project is built on Clean Architecture principles, divided into several core sections inside the `lib/features` folder:
- `auth`: Handles user login and account creation.
- `growth`: Manages measurement recordings and connects to the smart scale via Bluetooth.
- `meals`: Covers everything related to dietary plans, weekly meals, and AI integration.
- `settings`: Application settings and account information.

---

## 🚀 How to Run

1. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run the App:**
   ```bash
   flutter run
   ```

*(Note: To test the Bluetooth and smart scale features, you must run the app on a physical device, not an emulator).*

---
Hope you like the project! If you have any questions about the code or the architecture, feel free to ask! ✌️
