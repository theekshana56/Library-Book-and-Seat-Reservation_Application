# Biblione

Biblione is a library management and reservation application for students,
library staff, administrators, and book vendors. It combines a Flutter client
with a Spring Boot REST API backed by MongoDB.

The application supports:

- Searching the library catalogue and viewing book details
- Reserving available books and joining a waitlist for unavailable books
- Viewing, cancelling, and renewing bookings
- Finding library seats using filters and ranked seat recommendations
- Managing library users, shelves, halls, and seats
- Assigning staff shelving tasks and updating task status
- Submitting and reviewing publisher book proposals
- Loading a development catalogue and demonstration bookings automatically

## Project structure

```text
.
├── backend/       Spring Boot API and MongoDB integration
├── frontend/      Flutter application for Android, web, Windows, and other
│                  supported Flutter targets
└── .github/       Continuous integration workflow
```

## Technology stack

- **Frontend:** Flutter and Dart
- **Backend:** Java 17, Spring Boot 3.3.5, Spring Web, Spring Data MongoDB
- **Database:** MongoDB, including MongoDB Atlas
- **Build tools:** Flutter CLI and Maven
- **External service:** Google Books API for catalogue search

## Prerequisites

Install the following before running the application:

1. **Git**
2. **Java Development Kit (JDK) 17 or later**
3. **Apache Maven** (or a compatible Maven installation)
4. **Flutter SDK** on the stable channel
5. **Android Studio and Android SDK Platform-Tools** if you want to run on
   Android
6. A **MongoDB database**. MongoDB Atlas is recommended for development.
7. A Google Books API key if you want live Google Books catalogue searches.

Verify the main tools:

```powershell
java -version
mvn -version
flutter --version
flutter doctor
```

Resolve any errors reported by `flutter doctor` before starting the mobile
application. Android users must also enable USB debugging and authorize the
development computer on the device.

## Installation

Clone the repository and enter its directory:

```powershell
git clone https://github.com/theekshana56/Library-Book-and-Seat-Reservation_Application.git
Set-Location Library-Book-and-Seat-Reservation_Application
```

### 1. Configure the backend

Create a local environment file from the committed example:

```powershell
Copy-Item backend\.env.example backend\.env
```

Open `backend\.env` and set the following values:

```dotenv
MONGODB_USERNAME=your-mongodb-username
MONGODB_PASSWORD=your-mongodb-password
MONGODB_CLUSTER=cluster0.example.mongodb.net
MONGODB_DATABASE=biblione_db
SERVER_PORT=8080
```

The `backend\.env` file is ignored by Git. Do not commit database credentials.
The local launcher URL-encodes the username and password before creating the
MongoDB connection string.

In MongoDB Atlas, make sure the database user exists and that the development
machine's IP address is allowed by the project's Network Access settings.

### 2. Configure the Flutter app

Create the local Dart define file:

```powershell
Copy-Item frontend\dart_defines.example.json frontend\dart_defines.json
```

Edit `frontend\dart_defines.json`:

```json
{
  "API_BASE": "http://localhost:8080",
  "GOOGLE_BOOKS_API_KEY": "your-google-books-api-key"
}
```

`API_BASE` is optional for web and desktop because the client defaults to
`http://localhost:8080`. It is useful when the API is hosted elsewhere.
Android emulator and device instructions are provided below.

The Google Books key is compiled into the client and must not be treated as a
server-side secret after an app is distributed. Restrict it in Google Cloud to
the required API and applications.

Install Flutter dependencies:

```powershell
Set-Location frontend
flutter pub get
```

## Running the application

Start the backend before starting the Flutter client.

### Start the backend

From the repository root:

```powershell
Set-Location backend
.\run-local.ps1
```

The script reads `backend\.env`, builds `MONGODB_URI`, and runs
`mvn spring-boot:run`. The API is available at:

```text
http://localhost:8080
```

To run without the helper script, set `MONGODB_URI` in the process environment
and execute:

```powershell
Set-Location backend
mvn spring-boot:run
```

On the first start, the backend seeds sample books, seats, shelves, bookings,
and development user records. Seeding is enabled by default with
`biblione.seed=true`. Set it to `false` in
`backend\src\main\resources\application.properties` when the seed data is no
longer wanted.

The development seed password defaults to
`Biblione-ChangeMe-2026`. Override it with the `BIBLIONE_SEED_PASSWORD`
configuration/property before exposing the API outside a local development
environment. The seeded development accounts are:

| Account | Email | Role |
|---|---|---|
| Library Administrator | `admin@biblione.edu` | `ADMIN` |
| Library Staff | `staff@biblione.edu` | `LIBRARY_STAFF` |
| Biblione Books Vendor | `vendor@biblione.edu` | `VENDOR` |

These are development records only. Change the password and use proper
authentication before deploying the application.

### Run on a browser or desktop

Open a second terminal:

```powershell
Set-Location frontend
flutter run -d chrome --dart-define-from-file=dart_defines.json
```

To see available targets:

```powershell
flutter devices
```

For a Windows desktop target, use the device ID reported by `flutter devices`:

```powershell
flutter run -d windows --dart-define-from-file=dart_defines.json
```

### Run on an Android emulator

Start an emulator from Android Studio, then run:

```powershell
Set-Location frontend
flutter run -d emulator-5554 --dart-define-from-file=dart_defines.json
```

Replace `emulator-5554` with the ID shown by `flutter devices`. The Android
emulator can reach the host machine's API through `10.0.2.2`, which is the
default Android API address used by the app when `API_BASE` is not supplied.

### Run on a physical Android device

Connect the device over USB, enable USB debugging, and confirm that it is
authorized:

```powershell
adb devices
```

Then run the repository helper:

```powershell
Set-Location frontend
.\run-android-local.ps1 -DeviceId YOUR_DEVICE_ID
```

This forwards the API port with `adb reverse tcp:8080 tcp:8080` and starts
Flutter with `API_BASE=http://localhost:8080`. It avoids depending on a fixed
Wi-Fi address.

## Useful API routes

The backend base URL is `http://localhost:8080`. Main route groups include:

| Route | Purpose |
|---|---|
| `GET /api/v1/books` | Search or list catalogue books |
| `GET /api/v1/books/{id}` | Get one book |
| `POST /api/v1/reservations` | Reserve a book |
| `POST /api/v1/waitlist` | Join a book waitlist |
| `GET /api/v1/users/{userId}/bookings` | Get a user's bookings |
| `POST /api/v1/loans/{id}/renew` | Renew a loan |
| `POST /api/v1/seats/recommend` | Get ranked seat recommendations |
| `/api/v1/admin/*` | Administrative users, statistics, tasks, shelves, halls, and seats |
| `/api/v1/publisher/*` | Publisher proposal operations |

The Flutter demo client uses user ID `IT23773158` and displays the seeded
demonstration bookings for that user.

## Development commands

Run frontend static analysis and tests:

```powershell
Set-Location frontend
flutter analyze
flutter test
```

Build the backend and run its tests:

```powershell
Set-Location backend
mvn test
mvn package
```

Build an Android APK:

```powershell
Set-Location frontend
flutter build apk --dart-define-from-file=dart_defines.json
```

The generated debug APK is placed under Flutter's build output directory.
Build artifacts, local environment files, and generated Flutter files are
ignored by Git.

## Troubleshooting

### The frontend cannot connect to the API

- Confirm that the backend is running on port `8080`.
- Check `API_BASE` in `frontend\dart_defines.json`.
- For an Android emulator, use `http://10.0.2.2:8080`, not
  `http://localhost:8080`.
- For a physical Android device, use `run-android-local.ps1` or run
  `adb reverse tcp:8080 tcp:8080`.
- Confirm that the device is visible in `adb devices` and authorized.

### The backend cannot connect to MongoDB

- Check all values in `backend\.env`.
- Confirm that the Atlas IP allowlist includes the current machine.
- Confirm that the MongoDB user has access to `biblione_db`.
- If the password contains special characters, use the provided
  `run-local.ps1` script so it is escaped correctly.

### The Google Books search is unavailable

- Confirm that `GOOGLE_BOOKS_API_KEY` is set in
  `frontend\dart_defines.json`.
- Confirm that the Google Books API is enabled for the associated Google Cloud
  project.
- Restart Flutter after changing Dart defines.

## Continuous integration

The GitHub Actions workflow in `.github/workflows/dart.yml` runs on pushes and
pull requests targeting `main`. It installs Flutter dependencies, runs
`flutter analyze`, and runs `flutter test`.

## Security notes

- Never commit `backend\.env` or `frontend\dart_defines.json`.
- Do not use the seeded development password in a deployed environment.
- Restrict Google Books API keys in Google Cloud.
- Configure real authentication and authorization before exposing the API to
  untrusted users.

## License

No license file is currently included in this repository. Contact the project
owner before redistributing or reusing the application.
