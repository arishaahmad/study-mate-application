# Study Mate Application

A comprehensive mobile application designed to help students manage their studies, schedules, and tasks efficiently. Built with Flutter and Supabase, Study Mate provides essential productivity tools including class scheduling, task management, Pomodoro timer, note-taking, and a collaborative help forum.

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com/)

---

## Table of Contents

- [Features](#features)
- [Technology Stack](#technology-stack)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Project Structure](#project-structure)
- [Running the Application](#running-the-application)
- [Feature Implementation Status](#feature-implementation-status)
- [Team Members](#team-members)
- [License](#license)

---

## Features

#### 1. **User Authentication**
- Secure user registration and login system
- Email and password authentication via Supabase Auth
- Session management and persistent login
- Automatic session refresh

#### 2. **Class Schedule Management**
- Add and view course information
- Track course details including:
  - Course name and code
  - Class timings and days
  - Location/Room number
- Weekly schedule view with calendar integration
- Semester-based organization

#### 3. **Pomodoro Timer**
- Customizable study session timer
- Start, pause, and reset functionality
- Flexible timing configuration:
  - work sessions
  - short breaks
- Visual countdown display with progress indicator

#### 4. **To-Do List Management**
- Create new tasks with detailed descriptions
- Set due dates and times for tasks
- Mark tasks as complete/incomplete
- Edit and update existing tasks
- Delete completed or unwanted tasks

#### 5. **Help Forum**
- Community discussion board for student collaboration
- Post questions and share answers
- Real-time updates using Supabase Realtime

#### 6. **Notes Module**
- Create and organize study notes
- Rich text formatting support
- Cloud synchronization via Supabase Storage
- Offline access to saved notes

#### 7. **File Uploads**
- Photo upload from camera or gallery
- PDF document upload and viewing
- File attachment in notes
- Supabase Storage integration
- 
#### 8. **Notifications **
- Local push notifications

---

## Technology Stack

### Frontend Framework
- **Flutter** (v3.16.0) 
- **Dart** (v3.2.0)

### Backend Services
- **Supabase** - Backend-as-a-Service platform
  - PostgreSQL database
  - Authentication system
  - Real-time subscriptions
  - Storage for file uploads
  - Row Level Security (RLS)


### Key Flutter Packages
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Supabase
  supabase_flutter: ^2.0.0
  
  # UI Components
  flutter_slidable: ^3.0.0
  table_calendar: ^3.0.9
  percent_indicator: ^4.2.3
  
  # State Management
  provider: ^6.1.1
  
  # Local Storage
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  
  # Notifications
  flutter_local_notifications: ^16.3.0
  
  # File Handling
  file_picker: ^6.1.1
  image_picker: ^1.0.7
  
  # UI Utilities
  intl: ^0.19.0
  uuid: ^4.3.3
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
```

---

## Prerequisites

Before you begin, ensure you have the following installed:

### 1. **Flutter SDK** (v3.16.0 or higher)

Download and install Flutter from [flutter.dev](https://flutter.dev/docs/get-started/install)

Verify installation:
```bash
flutter --version
flutter doctor
```

### 2. **Dart SDK** (Included with Flutter)

Verify Dart installation:
```bash
dart --version
```

### 3. **IDE/Editor**

Choose one:
- **Android Studio** 
  - Install Flutter and Dart plugins
- **Visual Studio Code**
  - Install Flutter extension
  - Install Dart extension

### 4. **Platform-Specific Requirements**

#### For Android Development:
- **Android Studio** with Android SDK
- **Android Emulator** or physical Android device
- **Java JDK** (v11 or higher)

### 5. **Git**
```bash
git --version
```

### 6. **Supabase Account**
- Sign up at [supabase.com](https://supabase.com/)

---

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/arishaahmad/study-mate-application.git
cd study-mate-application
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

This command will download and install all the dependencies listed in `pubspec.yaml`.

### 3. Verify Flutter Installation

```bash
flutter doctor
```

Resolve any issues indicated by `flutter doctor` before proceeding.

---

## Configuration

### 1. Supabase Setup

#### Create a Supabase Project

1. Navigate to [Supabase Dashboard](https://app.supabase.com/)
2. Click **"New Project"**
3. Fill in project details:
   - **Project Name:** `study-mate`
   - **Database Password:** (create a secure password)
   - **Region:** (select closest to your location)
4. Click **"Create new project"**
5. Wait for project initialization (2-3 minutes)

#### Retrieve API Credentials

1. Go to **Settings** → **API**
2. Copy the following:
   - **Project URL** (e.g., `https://xxxxx.supabase.co`)
   - **Anon/Public Key** (starts with `eyJhbG...`)

### 2. Configure Environment Variables

Create a new file `lib/config/supabase_config.dart`:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_PROJECT_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

**Replace the placeholder values with your actual Supabase credentials.**

### 3. Initialize Supabase Client

The Supabase client is initialized in `lib/services/supabase_service.dart`.


### 4. Update Main Application Entry Point

In `lib/main.dart`, initialize Supabase before running the app.

---

## Project Structure

```
study-mate-application/
│
├── android/                   
├── ios/                       
├── lib/                    
│   │
│   ├── screens/             
│   │   │   ├── chat_screen.dart
│   │   │   ├── dashboard_screen.dart
│   │   │   └── help_forum.dart
│   │   │   └── inbox_screen.dart
│   │   │   ├── login_screen.dart
│   │   │   ├── notes_taking_screen.dart
│   │   │   └── pomodor_timer_screen.dart
│   │   │   ├── profile_screen.dart
│   │   │   └── timer_settings_screen.dart
│   │   │   ├── schedule_screen.dart
│   │   │   ├── signup_screen.dart
│   │   │   └── todo_list_screen.dart
│   │   ├── widgets/           
│   │       ├── login_form_widget.dart
│   │       ├── signup_form_widget.dart
│   │       └── note_detail_screen.dart
│   │
│   └── main.dart            
│
├── .gitignore              # Git ignore rules
├── pubspec.yaml            # Flutter dependencies
├── pubspec.lock            # Locked dependency versions
├── analysis_options.yaml   # Dart analyzer configuration
├── README.md               # This file
├── ProgressReport.pdf      # Project progress report
└── UpdatedProposalReportCNG495.pdf  # Project proposal
```

---

## Running the Application

### 1. Check Connected Devices

```bash
flutter devices
```


### 2. Run on Android Emulator

#### Start Android Emulator:
```bash
# List available emulators
emulator -list-avds

# Start specific emulator
emulator -avd <emulator_name>
```

#### Run the app:
```bash
flutter run
```

Or specify the device:
```bash
flutter run -d <device_id>
```

### 3. Run on iOS Simulator (macOS only)

```bash
# Open iOS simulator
open -a Simulator

# Run the app
flutter run
```

### 4. Run on Physical Device

#### Android:
1. Enable **Developer Options** and **USB Debugging** on your Android device
2. Connect device via USB
3. Run: `flutter run`


### 5. Hot Reload and Hot Restart

While the app is running:
- Press **`r`** in terminal for hot reload (fastest, preserves state)
- Press **`R`** in terminal for hot restart (restarts app, clears state)
- Press **`q`** to quit

### 6. Build Commands

#### Build APK (Android):
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Split APK by ABI (smaller size)
flutter build apk --split-per-abi
```

Output: `build/app/outputs/flutter-apk/`

#### Build App Bundle (Android - for Play Store):
```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/`

#### Build iOS App (macOS only):
```bash
flutter build ios --release
```

### 7. Development Commands

```bash
# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format lib/

# Clean build files
flutter clean

# Update dependencies
flutter pub upgrade

# Check for outdated packages
flutter pub outdated
```

---



## Feature Implementation Status

| Feature | Status | Timeline | Details |
|---------|--------|----------|---------|
| **User Authentication** | ✅ Complete | Week 1-3 | Registration, Login, Password Recovery, Session Management |
| **Class Schedule** | ✅ Complete | Week 4-5 | Add, View, Edit, Delete courses with calendar integration |
| **Pomodoro Timer** | ✅ Complete | Week 6-7 | Timer with Start, Pause, Reset, Session tracking |
| **To-Do List** | ✅ Complete | Week 8 | Full CRUD operations, Priorities, Due dates, Filters |
| **Help Forum** | ✅ Complete | Week 9 | Database schema design, Chat interface implementation |
| **Notes Module** | ✅ Complete | Week 9 | Text storage, Rich formatting, Cloud sync |
| **File Uploads** | ✅ Complete | Week 10 | Photo/PDF uploads for Forum and Notes |
| **Notifications** | ✅ Complete | Week 11 | Local push notifications for Timer and Tasks |

---


### Project Team

| Name | Student ID | Role | Contact |
|------|------------|------|---------|
| **Arisha Ahmad** | 2751923 | Full Stack Developer | [e275192@metu.edu.tr](mailto:e275192@metu.edu.tr) |
| **Faiez Rashid** | 2460384 | Full Stack Developer | [e246038@metu.edu.tr](mailto:e246038@metu.edu.tr) |


## Repository Information

- **Repository URL:** [https://github.com/arishaahmad/study-mate-application.git](https://github.com/arishaahmad/study-mate-application.git)
- **Project Type:** CNG495 Captsone Project
- **Platform:** Flutter (Android)

---


## Acknowledgments

- **Supabase** for providing an excellent Backend-as-a-Service platform
- **Flutter Team** for the amazing cross-platform framework
- **CNG495 Course Instructors** for guidance and support
- **Open Source Community** for various packages and resources used in this project

---

## Contact & Support

For questions, issues, or contributions:

1. **Open an issue** on GitHub: [Issues Page](https://github.com/arishaahmad/study-mate-application/issues)
2. **Email the team:**
   - Arisha Ahmad: e275192@metu.edu.tr
   - Faiez Rashid: e246038@metu.edu.tr
3. **Review project documentation** in the repository

---
