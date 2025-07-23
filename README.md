# Pawtroli - Pet Hotel Management System

![logo](https://github.com/user-attachments/assets/df30547c-f928-450d-9554-eecffa9d035b)

## Overview

Pawtroli is a comprehensive pet hotel management application that connects pet owners with hotel staff, providing real-time monitoring, communication, and care updates for pets staying at the hotel.

### Features

- 🔐 **User Authentication** - Separate workflows for pet owners and staff
- 💬 **Real-time Chat** - Direct communication between owners and caregivers
- 📹 **CCTV Monitoring** - Live streaming of pets for remote viewing
- 🐾 **Pet Management** - Registration, profiles, and care records
- 📊 **Admin Dashboard** - Complete management interface for staff

## Tech Stack

- **Frontend**: Flutter (Android, iOS, Windows, macOS, Linux)
- **Backend**: Go
- **Authentication**: Firebase Auth
- **Database**: Firestore
- **Media Streaming**: VLC integration for RTSP video streams

## Screenshots

<table>
  <tr>
    <td><img src="screenshots/login.png" alt="Login Screen" width="200"/></td>
    <td><img src="screenshots/dashboard.png" alt="Dashboard" width="200"/></td>
    <td><img src="screenshots/chat.png" alt="Chat Interface" width="200"/></td>
    <td><img src="screenshots/cctv.png" alt="CCTV Monitoring" width="200"/></td>
  </tr>
</table>

## Getting Started

### Prerequisites

- Flutter SDK (2.10.0 or later)
- Go (1.17 or later)
- Firebase account
- RTSP stream source (for CCTV functionality)

### Installation

#### Frontend (Flutter)

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/pawtroli.git
   cd pawtroli/frontend
   ```

2. Install dependencies:
   ```
   flutter pub get
   ```

3. Configure Firebase:
   - Create a Firebase project
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) to the respective directories
   - Update Firebase configuration in `lib/config/firebase_config.dart`

4. Run the application:
   ```
   flutter run
   ```

#### Backend (Go)

1. Navigate to the backend directory:
   ```
   cd pawtroli/backend
   ```

2. Install Go dependencies:
   ```
   go mod download
   ```

3. Configure environment variables (create a `.env` file based on `.env.example`)

4. Run the server:
   ```
   go run main.go
   ```

## Project Structure

```
pawtroli/
├── frontend/               # Flutter application
│   ├── lib/
│   │   ├── main.dart       # Entry point
│   │   ├── screens/        # UI screens
│   │   ├── widgets/        # Reusable UI components
│   │   ├── models/         # Data models
│   │   ├── services/       # Business logic and API services
│   │   └── utils/          # Helper functions
│   ├── assets/             # Images, fonts, etc.
│   └── test/               # Unit and widget tests
│
└── backend/                # Go server
    ├── main.go             # Entry point
    ├── api/                # API endpoints
    ├── models/             # Data models
    ├── services/           # Business logic
    └── utils/              # Helper functions
```

## API Documentation

The backend provides RESTful APIs for:

- User authentication and management
- Pet registration and updates
- Chat messages
- CCTV stream management

For detailed API documentation, see [API_DOCS.md](API_DOCS.md).

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Flutter](https://flutter.dev/)
- [Go](https://golang.org/)
- [Firebase](https://firebase.google.com/)
- [VLC for Flutter](https://pub.dev/packages/flutter_vlc_player)
