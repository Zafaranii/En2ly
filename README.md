# En2ly

## Overview
En2ly is a mobile application designed to provide a seamless ride-hailing experience for passengers. The app allows users to request rides, track drivers in real-time, manage payments, and access trip history effortlessly.

## Features
- **Ride Booking**: Request a ride to any destination.
- **Real-time Tracking**: Track driver location and estimated arrival time.
- **Payment Integration**: Multiple payment options including card and wallet.
- **Trip History**: View past trips and fare breakdowns.
- **Profile Management**: Edit user details and preferences.

## Tech Stack
- **Frontend**: Flutter
- **Backend**: Firebase
- **State Management**: Provider / Riverpod (if applicable)
- **Authentication**: Firebase Authentication
- **Maps & Navigation**: Google Maps API

## Installation
### Prerequisites
- Flutter SDK installed ([Download here](https://flutter.dev/docs/get-started/install))
- Android Studio / Xcode for running the app
- Firebase project setup (for backend functionality)

### Steps
1. Clone the repository:
   ```sh
   git clone https://github.com/Zafaranii/En2ly.git
   cd En2ly
   ```
2. Install dependencies:
   ```sh
   flutter pub get
   ```
3. Run the app:
   ```sh
   flutter run
   ```
   *(Ensure a simulator/emulator or physical device is connected.)*

## Project Structure
```
En2ly/
│-- lib/
│   │-- main.dart         # Entry point of the app
│   │-- screens/          # UI screens
│   │-- providers/        # State management
│   │-- services/         # Firebase and API services
│   │-- widgets/          # Reusable UI components
│-- assets/               # Images and other assets
│-- pubspec.yaml          # Dependencies and configurations
│-- android/              # Android-specific files
│-- ios/                  # iOS-specific files
```

## Contributing
1. Fork the repository.
2. Create a new branch:
   ```sh
   git checkout -b feature-name
   ```
3. Commit your changes:
   ```sh
   git commit -m "Add new feature"
   ```
4. Push the branch:
   ```sh
   git push origin feature-name
   ```
5. Open a pull request.

## License
This project is licensed under the MIT License.

## Contact
For inquiries, contact **Marwan Hazem** at [marwan.elzafarani@gmail.com](mailto:marwan.elzafarani@gmail.com).
