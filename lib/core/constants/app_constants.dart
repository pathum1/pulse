/// App Constants for Pulse Track
class AppConstants {
  // App Info
  static const String appName = 'Pulse Track';
  static const String appVersion = '1.0.0';
  
  // Database Collections
  static const String surgeonsCollection = 'surgeons';
  static const String surgeriesCollection = 'surgeries';
  static const String surgeryTypesCollection = 'surgery_types';
  static const String notificationsCollection = 'notifications';
  
  // Notification Constants
  static const int surgeryReminderNotificationId = 1001;
  static const int overdueNotificationId = 1002;
  static const int checkInReminderNotificationId = 1003;
  
  // Notification Channels
  static const String surgeryChannel = 'surgery_notifications';
  static const String reminderChannel = 'reminder_notifications';
  static const String urgentChannel = 'urgent_notifications';
  
  // Surgery Status
  static const String statusScheduled = 'scheduled';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';
  static const String statusOverdue = 'overdue';
  
  // Surgeon Availability Status
  static const String availabilityAvailable = 'available';
  static const String availabilityBusy = 'busy';
  static const String availabilityOnLeave = 'on_leave';
  static const String availabilityInSurgery = 'in_surgery';
  
  // Time Constants (in minutes)
  static const int overdueReminderInterval = 30; // 30 minutes
  static const int checkInReminderInterval = 60; // 1 hour
  static const int surgeryReminderDefault = 30; // 30 minutes before surgery
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxSurgeriesPerDay = 10;
  
  // Storage Keys
  static const String userIdKey = 'user_id';
  static const String isLoggedInKey = 'is_logged_in';
  static const String themeKey = 'theme_mode';
  static const String notificationSettingsKey = 'notification_settings';
  static const String lastCheckInKey = 'last_check_in';
  
  // Firebase Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String surgeryDocumentsPath = 'surgery_documents';
  
  // Common Surgery Types (for initial data)
  static const List<Map<String, dynamic>> commonSurgeryTypes = [
    {
      'name': 'Appendectomy',
      'category': 'General Surgery',
      'averageDuration': 90, // minutes
      'description': 'Surgical removal of the appendix'
    },
    {
      'name': 'Cholecystectomy',
      'category': 'General Surgery',
      'averageDuration': 120,
      'description': 'Surgical removal of the gallbladder'
    },
    {
      'name': 'Hernia Repair',
      'category': 'General Surgery',
      'averageDuration': 75,
      'description': 'Surgical repair of hernia'
    },
    {
      'name': 'Coronary Artery Bypass',
      'category': 'Cardiac Surgery',
      'averageDuration': 240,
      'description': 'Heart bypass surgery'
    },
    {
      'name': 'Hip Replacement',
      'category': 'Orthopedic Surgery',
      'averageDuration': 180,
      'description': 'Total hip joint replacement'
    },
    {
      'name': 'Knee Arthroscopy',
      'category': 'Orthopedic Surgery',
      'averageDuration': 60,
      'description': 'Minimally invasive knee surgery'
    },
    {
      'name': 'Cataract Surgery',
      'category': 'Ophthalmology',
      'averageDuration': 30,
      'description': 'Removal of cataract from eye lens'
    },
    {
      'name': 'Tonsillectomy',
      'category': 'ENT Surgery',
      'averageDuration': 45,
      'description': 'Surgical removal of tonsils'
    },
    {
      'name': 'Cesarean Section',
      'category': 'Obstetrics',
      'averageDuration': 60,
      'description': 'Surgical delivery of baby'
    },
    {
      'name': 'Brain Tumor Resection',
      'category': 'Neurosurgery',
      'averageDuration': 300,
      'description': 'Surgical removal of brain tumor'
    },
  ];
  
  // Surgery Categories
  static const List<String> surgeryCategories = [
    'General Surgery',
    'Cardiac Surgery',
    'Orthopedic Surgery',
    'Neurosurgery',
    'Plastic Surgery',
    'Ophthalmology',
    'ENT Surgery',
    'Urology',
    'Gynecology',
    'Obstetrics',
    'Pediatric Surgery',
    'Emergency Surgery',
  ];
  
  // Operating Rooms
  static const List<String> operatingRooms = [
    'OR-1',
    'OR-2',
    'OR-3',
    'OR-4',
    'OR-5',
    'OR-6',
    'OR-7',
    'OR-8',
    'Emergency OR-1',
    'Emergency OR-2',
  ];
  
  // Validation Constants
  static const int minPatientNameLength = 2;
  static const int maxPatientNameLength = 50;
  static const int minSurgeonNameLength = 2;
  static const int maxSurgeonNameLength = 50;
  static const int minSurgeryDuration = 15; // minutes
  static const int maxSurgeryDuration = 720; // 12 hours
  
  // Error Messages
  static const String networkErrorMessage = 'Please check your internet connection and try again';
  static const String unknownErrorMessage = 'Something went wrong. Please try again';
  static const String authErrorMessage = 'Authentication failed. Please sign in again';
  static const String permissionErrorMessage = 'Permission denied. Please contact your administrator';
}