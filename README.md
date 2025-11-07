# Pulse Track - Surgery Management System

A comprehensive Flutter app designed specifically for hospital surgeons to manage their surgery schedules, coordinate with colleagues, and receive reliable notifications.

## 🏥 Features

### Core Functionality
- **Personal Surgery Scheduling**: Self-schedule surgeries with patient details and estimated duration
- **Daily Check-In System**: Mark daily availability status
- **Real-time Notifications**: Reliable background notifications for surgery reminders and overdue alerts
- **Hospital-Wide Calendar**: View all surgeries across the hospital
- **Surgery Status Tracking**: Track surgeries from scheduled to completed
- **Profile Management**: View surgery history and manage contact details

### Advanced Features
- **Smart Notifications**: 
  - Configurable surgery reminders (default: 30 minutes before)
  - Automatic overdue notifications every 30 minutes
  - Interactive notifications with quick actions
- **Surgery Repository**: Searchable database of common surgery types
- **Availability Management**: Real-time surgeon status (available, busy, in surgery, on leave)
- **Offline Support**: Works offline with automatic sync when online

## 🎨 Design System

### Color Palette
- **Primary**: Surgical Teal (`#009CA6`) - Professional, medical association
- **Secondary**: Deep Indigo (`#2F3C7E`) - Authority and contrast
- **Accent**: Warm Coral (`#F45B69`) - Urgent notifications and alerts

### UI Principles
- Medical-grade reliability and clarity
- Accessible design (WCAG compliance)
- Intuitive navigation optimized for busy surgeons
- Beautiful animations and smooth transitions

## 🏗️ Architecture

### Clean Architecture
```
lib/
├── core/                    # Core functionality
│   ├── constants/          # App constants
│   ├── services/           # Firebase, Notifications
│   ├── theme/              # App themes and colors
│   └── utils/              # Utility functions
├── features/               # Feature modules
│   ├── auth/               # Authentication
│   ├── surgery/            # Surgery management
│   ├── schedule/           # Schedule views
│   └── profile/            # User profile
└── shared/                 # Shared components
    ├── models/             # Data models
    └── widgets/            # Reusable widgets
```

### State Management
- **BLoC Pattern**: Robust state management with flutter_bloc
- **Repository Pattern**: Clean data layer separation
- **Firebase Integration**: Real-time data synchronization

### Key Technologies
- **Flutter 3.5+**: Cross-platform mobile framework
- **Firebase**: Authentication, Firestore, Cloud Messaging
- **BLoC**: State management
- **GoRouter**: Declarative routing
- **Hive**: Local storage and offline support

## 🔧 Setup Instructions

### Prerequisites
- Flutter SDK 3.5+
- Firebase account
- Android Studio / VS Code
- Physical Android device (for notification testing)

### Installation
1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd pulse/pulse
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Follow instructions in `setup_firebase.md`
   - Configure authentication providers
   - Set up Firestore database
   - Enable Cloud Messaging

4. **Run the app**
   ```bash
   flutter run
   ```

## 📱 App Flow

### Authentication Flow
1. **Splash Screen**: Initialize services and check auth state
2. **Onboarding**: Feature introduction for new users
3. **Login**: Google Sign-In or email/password authentication
4. **Check-In**: Daily availability confirmation

### Main App Flow
1. **My Schedule**: Personal surgery schedule (homepage)
2. **Hospital Calendar**: Hospital-wide surgery overview
3. **Create Surgery**: Schedule new surgeries with patient details
4. **Profile**: Personal information and surgery statistics

### Notification Flow
- **Surgery Reminders**: Configurable pre-surgery notifications
- **Overdue Alerts**: Automatic alerts for surgeries running overtime
- **Check-In Reminders**: Daily availability reminders
- **Interactive Actions**: Quick actions directly from notifications

## 📊 Data Models

### Core Models
- **Surgeon**: User profile with availability status and statistics
- **Surgery**: Complete surgery information with patient details
- **SurgeryType**: Repository of common surgery procedures

### Key Fields
```dart
Surgery {
  - Patient information (name, ID, age, gender)
  - Surgery details (type, duration, room)
  - Scheduling (start time, estimated end)
  - Status tracking (scheduled, in-progress, completed)
  - Notification settings (reminder minutes)
}
```

## 🔔 Notification System

### Notification Types
- **Surgery Reminders**: Pre-surgery notifications
- **Overdue Alerts**: Surgery running overtime
- **Check-In Reminders**: Daily availability prompts

### Features
- Background processing for reliable delivery
- Interactive actions (mark complete, snooze, etc.)
- Customizable reminder timing
- Multiple notification channels with different priorities

## 🎯 User Experience

### For Surgeons
- **Quick Check-In**: Single-tap daily availability
- **Smart Scheduling**: Search surgery repository with autocomplete
- **Status Awareness**: Always know who's available and what's happening
- **Reliable Alerts**: Never miss a surgery or forget to mark completion

### For Hospital Administration
- **Visibility**: Real-time view of all surgical activities
- **Coordination**: Improved surgeon scheduling and availability
- **Efficiency**: Reduced manual coordination overhead

## 🚀 Future Enhancements

### Planned Features
- **Push Notifications**: Server-side notification delivery
- **Surgery Templates**: Pre-filled surgery forms for common procedures
- **Team Messaging**: In-app communication for surgical teams
- **Analytics Dashboard**: Surgery completion statistics and trends
- **Equipment Tracking**: Operating room and equipment availability
- **Integration APIs**: Connect with existing hospital management systems

### Technical Improvements
- **Advanced Offline Support**: Full offline functionality
- **Performance Optimization**: Lazy loading and caching
- **Accessibility Enhancements**: Screen reader support and larger fonts
- **Multi-language Support**: Localization for international hospitals

## 📞 Support

For technical support or feature requests:
- Create an issue in the repository
- Contact the development team
- Refer to the troubleshooting guide in `setup_firebase.md`

## 📄 License

Proprietary software for hospital use only. All rights reserved.

---

**Pulse Track** - Empowering surgeons with reliable scheduling and coordination tools. 🏥✨
