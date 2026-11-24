# REBS HRMS – Offline-Capable Employee Workspace

A Flutter-based employee workspace built for the REBS HRMS assignment. The application supports employee dashboard information, GPS-based attendance, offline attendance recording, synchronization, and leave management.

## 1. Project Overview

REBS HRMS allows employees to:

- View employee information and attendance status.
- Check in and check out using GPS-based office geofencing.
- Record attendance while offline.
- Store pending attendance events locally.
- Synchronize pending events when connectivity returns.
- View leave balance and leave requests.
- Submit leave requests with validation.

**Target platforms:** Android and iOS  
**Frontend:** Flutter and Dart  
**State management:** GetX  
**Backend:** Node.js and Express mock REST API

## 2. Architecture

The application follows a service-based structure with separation between UI, state management, data models, and backend/local storage operations.

### Architecture components

| Layer | Responsibility |
|---|---|
| Screens | Display dashboard, attendance, and leave UI |
| Controllers | Manage application state and business logic using GetX |
| Models | Represent employee, attendance, and leave data |
| API Services | Communicate with the mock REST API |
| Local Database Service | Persist attendance events for offline access |
| Location Service | Retrieve GPS coordinates and calculate office distance |
| Connectivity | Detect network changes and trigger synchronization |

### Data flow

1. Screens request information through GetX controllers.
2. Controllers communicate with API and local database services.
3. Dashboard information is loaded from the mock API.
4. Attendance events are saved locally before synchronization.
5. Pending events are submitted to the API in chronological order.
6. Successful events are marked as Synced.

## 3. Project Structure

```text
rebshrms/
├── android/
├── ios/
├── lib/
│   ├── controllers/
│   ├── models/
│   ├── screens/
│   ├── services/
│   ├── utils/
│   └── main.dart
├── mock_api/
│   ├── server.js
│   ├── package.json
│   └── package-lock.json
├── test/
├── pubspec.yaml
├── pubspec.lock
└── README.md
```

## 4. Prerequisites

Install the following:

- Flutter SDK
- Dart SDK
- Android Studio or VS Code
- Node.js and npm
- Android emulator or physical Android device

## 5. Flutter Application Setup

Clone the repository:

```bash
git clone https://github.com/FlutterDevSangee/REBS-HRMS.git
```

Navigate to the project:

```bash
cd REBS-HRMS
```

Install Flutter dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

## 6. Mock API Setup

The project includes a Node.js and Express mock API to simulate backend operations.

Navigate to the API directory:

```bash
cd mock_api
```

Install dependencies:

```bash
npm install
```

Start the API:

```bash
npm start
```

The API runs at:

```text
http://localhost:3000
```

Keep the API terminal open while running the Flutter application.

### API base URL configuration

Use the correct address for your platform:

| Platform | Base URL |
|---|---|
| Android Emulator | http://10.0.2.2:3000 |
| iOS Simulator | http://localhost:3000 |
| Physical Android | http://YOUR_COMPUTER_LAN_IP:3000 |

For a physical Android device, connect the phone and computer to the same Wi-Fi network and use the computer's LAN IP.

### Available API endpoints

| Method | Endpoint | Description |
|---|---|---|
| GET | `/employee/me` | Get employee details |
| GET | `/attendance?month=YYYY-MM` | Get attendance history |
| POST | `/attendance/events` | Submit attendance events |
| GET | `/leave/balance` | Get available leave balance |
| GET | `/leave/requests` | Get leave requests |
| POST | `/leave/requests` | Submit leave requests |

### Mock API test scenarios

The mock API supports configurable scenarios using the `SCENARIO` environment variable.

**Success:**

```powershell
$env:SCENARIO="success"
npm start
```

**Slow response:**

```powershell
$env:SCENARIO="slow"
npm start
```

**Server error:**

```powershell
$env:SCENARIO="server-error"
npm start
```

**Leave validation failure:**

```powershell
$env:SCENARIO="leave-reject"
npm start
```

Restart the API with the required scenario to switch test cases.

### Verify the API

Open this URL in a browser:

```text
http://localhost:3000/employee/me
```

A successful response should return employee information in JSON format.

## 7. Offline Attendance and Synchronization

The application is designed to support attendance recording when internet connectivity is unavailable.

The workflow is:

1. Retrieve the employee's current GPS location.
2. Validate the location against the configured office geofence.
3. Create a unique attendance event ID.
4. Save the event in local storage.
5. Mark the event as Pending Sync.
6. Detect connectivity changes.
7. Submit pending events when connectivity returns.
8. Mark successfully submitted events as Synced.

Attendance events use unique event IDs to support safe retries, provided the backend implements idempotency.

### Attendance statuses

- Pending Sync – Event saved locally and waiting for synchronization.
- Synced – Event successfully synchronized with the API.
- Rejected – Server rejected the event.

The application attempts synchronization when connectivity is restored and also supports manual synchronization.

## 8. Attendance and GPS Configuration

The application uses office coordinates and an allowed radius returned by employee configuration.

Example:

```json
{
  "office": {
    "latitude": 11.8745,
    "longitude": 75.3738,
    "allowedRadiusMeters": 200
  }
}
```

The employee must be within the configured radius to record attendance.

Location permissions must be granted, and GPS must be enabled.

For production, location validation and attendance timestamps must also be verified by the backend. Client-side GPS validation alone is not a security boundary.

## 9. Leave Management

The leave module supports leave balance and leave request operations.

Leave validation requirements:

- Leave type must be Casual or Sick.
- Start date must not be earlier than the company date.
- End date must be on or after the start date.
- Reason must contain at least 10 non-whitespace characters.
- Requested days must not exceed available leave balance.
- Overlapping Pending or Approved leave requests must be rejected.
- Leave duration is calculated using calendar days.

Leave requests can be viewed offline when previously loaded. Submission requires network connectivity.

The backend must repeat all important validations before accepting a request.

## 10. Assumptions

- The application uses a preconfigured employee; a login flow is not required.
- Employee and office information are provided by the mock API.
- Office geofence radius is configured by the backend.
- The company timezone is supplied through employee configuration.
- Attendance events are saved locally before attempting synchronization.
- Internet connectivity is required for server synchronization and leave submission.
- GPS permission and location services are required for attendance recording.
- The mock API is intended for development and assignment demonstration.

## 11. Completed Features

Update this section to reflect the features verified in the submitted build.

- Employee dashboard and employee information.
- Attendance check-in and check-out.
- GPS-based office geofence validation.
- Local attendance event storage.
- Pending Sync, Synced, and Rejected event statuses.
- Connectivity monitoring.
- Automatic and manual synchronization attempts.
- Employee attendance history.
- Leave balance and leave request integration.
- Mock REST API integration.

## 12. Limitations

- The mock API uses in-memory data, so server-side records may reset after restarting the server.
- The mock API is not intended for production deployment.
- Authentication and role-based access control are outside the current assignment scope.
- Background synchronization after the application is terminated is not implemented.
- Network connectivity detection does not guarantee that the API is reachable.
- Production deployment requires HTTPS, persistent backend storage, secure authentication, and server-side validation.
- GPS accuracy can vary depending on the device and environment.
- The mock API does not replace a production HRMS backend.

## 13. Testing

Recommended verification scenarios:

| Test | Expected result |
|---|---|
| Checkout without check-in | Rejected |
| Duplicate check-in | Rejected |
| Attendance while offline | Saved as Pending Sync |
| Restart application | Pending event remains available |
| Reconnect internet | Pending event synchronization attempted |
| Retry an event | Same event ID reused |
| Overlapping leave request | Validation error |
| Invalid leave reason | Validation error |
| Valid leave request | Submitted to API |

Run Flutter analysis:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

Only report tests as passed after running them successfully.

## 14. Build Debug APK

Run:

```bash
flutter clean
flutter pub get
flutter build apk --debug
```

APK output:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

Install on a connected Android device:

```bash
flutter install
```

## 15. Demonstration Video

The demonstration video should be approximately 3–5 minutes and show:

1. Dashboard loading.
2. Online check-in.
3. Offline attendance action.
4. Application restart with pending attendance preserved.
5. Synchronization after reconnecting.
6. Leave validation and submission.



https://github.com/user-attachments/assets/5eed24f2-ae5b-4529-b8e3-6c2842187249



## 16. Time Spent

**Total development time:** [6]

The implementation includes Flutter UI development, GetX state management, API integration, GPS attendance validation, local persistence, connectivity handling, synchronization, leave management, testing, and documentation.

## 17. Author

**Project:** REBS HRMS – Offline-Capable Employee Workspace  
**Technology:** Flutter, Dart, GetX, Node.js, Express  
**Repository:** https://github.com/FlutterDevSangee/REBS-HRMS
