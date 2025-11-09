# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Core Development
- `flutter pub get` - Install dependencies
- `flutter run` - Run main app on connected device
- `flutter run lib/main_debug.dart` - Run debug version
- `flutter run lib/main_simple.dart` - Run simplified version

### Testing & Analysis
- `flutter test` - Run unit tests
- `flutter analyze` - Static code analysis
- `dart run test_firebase.dart` - Test Firebase connection

### Build & Clean
- `flutter clean` - Clean build artifacts
- `flutter pub get` - Reinstall dependencies
- `flutter build apk` - Build Android APK

### Convenient Scripts
- `run_debug.bat` - Run debug version
- `run_simple.bat` - Run simple version  
- `clean_rebuild.bat` - Clean and rebuild project
- `test_firebase.bat` - Test Firebase connectivity

## Architecture Overview

### Clean Architecture Structure
The app follows Clean Architecture with feature-based organization:

```
lib/
├── core/                    # Core functionality
│   ├── constants/          # App-wide constants
│   ├── services/           # Firebase & Notifications
│   └── theme/              # Material Design theme
├── features/               # Feature modules (auth, surgery, schedule, profile)
│   └── [feature]/
│       └── presentation/
│           └── pages/
└── shared/                 # Shared components
    ├── models/             # Data models (Surgery, Surgeon, SurgeryType)
    └── widgets/            # Reusable UI widgets
```

### Key Technologies
- **Flutter 3.5+** with Material 3 design system
- **Firebase** (Auth, Firestore, Cloud Messaging)
- **BLoC Pattern** for state management (flutter_bloc)
- **GoRouter** for declarative navigation
- **Hive** for local storage and offline support

### Core Models
- **Surgery**: Enhanced with audit tracking, postponement history, patient references
- **Patient**: Auto-generated alphanumeric ID (format: PXX####XX), medical details
- **Surgeon**: User profile with availability status and statistics
- **SurgeryType**: Repository of common surgery procedures
- **PostponementHistory**: Tracks surgery rescheduling with reasons
- **SurgeryAuditEntry**: Comprehensive edit tracking (created/modified by)

### Navigation & Routing
Uses GoRouter with shell routing for bottom navigation:
- `/splash` → `/onboarding` → `/login` → `/setup-profile` → `/calendar`
- Main shell: `/calendar` (home), `/today`, `/patients`, `/profile`
- Nested routes: `/calendar/surgery/:surgeryId` for surgery details
- **Mandatory Profile Setup**: First-time users must complete profile before accessing main app

**New Architecture**: Shared hospital calendar system with no check-in requirements

### Firebase Integration
- **Authentication**: Google Sign-In + email/password
- **Firestore**: Real-time surgery data sync
- **Cloud Messaging**: Push notifications for surgery reminders
- **Setup**: Follow `setup_firebase.md` for configuration

### State Management
- BLoC pattern with repositories for data layer
- Real-time Firestore streams for live data updates
- Offline support with Hive local storage

### Notification System
- **Local notifications**: Surgery reminders, overdue alerts
- **Background processing**: Reliable notification delivery
- **Interactive actions**: Quick actions from notifications
- **Multiple channels**: Different priorities for different notification types

### Design System
- **Primary**: Surgical Teal (#009CA6) - medical professionalism
- **Secondary**: Deep Indigo (#2F3C7E) - authority and contrast  
- **Accent**: Warm Coral (#F45B69) - urgent notifications
- **Theme**: Light/dark mode support with system detection
- **Components**: Material 3 with medical-grade clarity and accessibility

### Testing Strategy
- Widget tests in `test/` directory
- Firebase connection testing with dedicated script
- Physical device required for notification testing
- Use `flutter test` for running test suite

### Key Features Implemented
- **Shared Calendar System**: Hospital-wide surgery calendar as homepage
- **TableCalendar Integration**: Swipeable month-wise calendar with surgery markers
- **Day-Tap Dialogs**: Comprehensive surgery management when tapping calendar days
- **Today's Surgeries Page**: Filtered view with status management and summary statistics
- **Postponement Tracking**: Visual indicators and history for rescheduled surgeries
- **Audit System**: Complete tracking of who created/modified surgeries
- **Patient Management**: Dedicated patient records with unique alphanumeric IDs
- **Calendar Rollback**: Undo functionality for recent changes (1 hour/1 day)
- **Status Management**: Real-time surgery status updates with progress tracking
- **Mandatory Profile Setup**: Multi-step profile creation with specializations and contact info
- **Patient Dropdown Search**: Real-time patient search when creating surgeries
- **No Check-in Requirements**: Direct access to calendar after profile completion

### Common Development Patterns
- Feature modules with presentation/data separation
- Equatable models for value comparison
- Factory constructors for Firestore document conversion
- Extension methods for formatted display text
- Status enums with display text getters
- Real-time calculation properties (isOverdue, timeRunning, hasPostponementIndicator)
- Comprehensive audit tracking with timestamp and user tracking
- Patient reference system with dropdown search capabilities