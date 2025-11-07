import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:firebase_messaging/firebase_messaging.dart';
import '../constants/app_constants.dart';

/// Notification Service
/// Handles both local and push notifications for surgery management
class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance => _instance ??= NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone
      tz.initializeTimeZones();

      // Android initialization settings
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const DarwinInitializationSettings iOSInitializationSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Initialization settings
      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: androidInitializationSettings,
        iOS: iOSInitializationSettings,
      );

      // Initialize local notifications
      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      // Create notification channels for Android
      await _createNotificationChannels();

      _isInitialized = true;
      print('Notification service initialized successfully');
    } catch (e) {
      print('Error initializing notification service: $e');
      rethrow;
    }
  }

  /// Create Android notification channels
  Future<void> _createNotificationChannels() async {
    if (!Platform.isAndroid) return;

    // Surgery notifications channel
    const AndroidNotificationChannel surgeryChannel = AndroidNotificationChannel(
      AppConstants.surgeryChannel,
      'Surgery Notifications',
      description: 'Notifications related to scheduled surgeries',
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      enableVibration: true,
      enableLights: true,
      ledColor: Color(0xFF009CA6),
    );

    // Reminder notifications channel
    const AndroidNotificationChannel reminderChannel = AndroidNotificationChannel(
      AppConstants.reminderChannel,
      'Reminder Notifications',
      description: 'General reminder notifications',
      importance: Importance.defaultImportance,
      enableVibration: true,
    );

    // Urgent notifications channel
    const AndroidNotificationChannel urgentChannel = AndroidNotificationChannel(
      AppConstants.urgentChannel,
      'Urgent Notifications',
      description: 'Critical and urgent notifications',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('urgent_notification'),
      enableVibration: true,
      enableLights: true,
      ledColor: Color(0xFFF45B69),
      playSound: true,
    );

    // Create channels
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(surgeryChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(reminderChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(urgentChannel);
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse notificationResponse) {
    final payload = notificationResponse.payload;
    if (payload != null) {
      print('Notification tapped with payload: $payload');
      // Handle navigation based on payload
      _handleNotificationNavigation(payload);
    }
  }

  /// Handle notification navigation
  void _handleNotificationNavigation(String payload) {
    try {
      // Parse payload and navigate to appropriate screen
      // This will be connected to the app's navigation system
      print('Handling notification navigation: $payload');
      
      // Example payload format: "surgery_reminder:surgeryId" or "surgery_overdue:surgeryId"
      final parts = payload.split(':');
      if (parts.length == 2) {
        final action = parts[0];
        final surgeryId = parts[1];
        
        switch (action) {
          case 'surgery_reminder':
            // Navigate to surgery details
            print('Navigate to surgery details: $surgeryId');
            break;
          case 'surgery_overdue':
            // Navigate to surgery with overdue actions
            print('Navigate to overdue surgery: $surgeryId');
            break;
          case 'check_in_reminder':
            // Navigate to check-in screen
            print('Navigate to check-in screen');
            break;
        }
      }
    } catch (e) {
      print('Error handling notification navigation: $e');
    }
  }

  /// Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = AppConstants.surgeryChannel,
    bool isUrgent = false,
    Map<String, String>? actions,
  }) async {
    try {
      // Determine channel and priority based on urgency
      final channel = isUrgent ? AppConstants.urgentChannel : channelId;
      final priority = isUrgent ? Priority.max : Priority.high;
      final importance = isUrgent ? Importance.max : Importance.high;

      // Android notification details
      AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        channel,
        channelId == AppConstants.surgeryChannel ? 'Surgery Notifications' : 'Reminder Notifications',
        importance: importance,
        priority: priority,
        showWhen: true,
        when: DateTime.now().millisecondsSinceEpoch,
        usesChronometer: false,
        enableVibration: true,
        enableLights: true,
        color: const Color(0xFF009CA6),
        ledColor: isUrgent ? const Color(0xFFF45B69) : const Color(0xFF009CA6),
        ledOnMs: 1000,
        ledOffMs: 500,
        ticker: title,
        actions: actions != null ? _buildNotificationActions(actions) : null,
      );

      // iOS notification details
      const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        badgeNumber: 1,
      );

      // Platform-specific details
      NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      // Show notification
      await _localNotifications.show(
        id,
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );

      print('Notification shown: $title');
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  /// Build notification actions for Android
  List<AndroidNotificationAction> _buildNotificationActions(Map<String, String> actions) {
    return actions.entries.map((entry) {
      return AndroidNotificationAction(
        entry.key,
        entry.value,
        titleColor: const Color(0xFF009CA6),
        showsUserInterface: true,
      );
    }).toList();
  }

  /// Schedule notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    String channelId = AppConstants.surgeryChannel,
    bool isUrgent = false,
    Map<String, String>? actions,
  }) async {
    try {
      // Convert to timezone aware datetime
      final scheduledTime = tz.TZDateTime.from(scheduledDate, tz.local);

      // Don't schedule if time is in the past
      if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
        print('Cannot schedule notification in the past');
        return;
      }

      // Determine channel and priority
      final channel = isUrgent ? AppConstants.urgentChannel : channelId;
      final priority = isUrgent ? Priority.max : Priority.high;
      final importance = isUrgent ? Importance.max : Importance.high;

      // Android notification details
      AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        channel,
        channelId == AppConstants.surgeryChannel ? 'Surgery Notifications' : 'Reminder Notifications',
        importance: importance,
        priority: priority,
        showWhen: true,
        when: scheduledDate.millisecondsSinceEpoch,
        enableVibration: true,
        enableLights: true,
        color: const Color(0xFF009CA6),
        ledColor: isUrgent ? const Color(0xFFF45B69) : const Color(0xFF009CA6),
        ticker: title,
        actions: actions != null ? _buildNotificationActions(actions) : null,
      );

      // iOS notification details
      const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      // Platform-specific details
      NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      // Schedule notification
      await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        scheduledTime,
        platformChannelSpecifics,
        payload: payload,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      print('Notification scheduled for: $scheduledDate');
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  /// Schedule surgery reminder notification
  Future<void> scheduleSurgeryReminder({
    required String surgeryId,
    required String surgeonName,
    required String patientName,
    required String surgeryType,
    required DateTime surgeryTime,
    required int reminderMinutes,
  }) async {
    final remindTime = surgeryTime.subtract(Duration(minutes: reminderMinutes));
    final timeString = '${surgeryTime.hour.toString().padLeft(2, '0')}:${surgeryTime.minute.toString().padLeft(2, '0')}';

    await scheduleNotification(
      id: AppConstants.surgeryReminderNotificationId + surgeryId.hashCode,
      title: 'Upcoming Surgery',
      body: '$patientName - $surgeryType at $timeString',
      scheduledDate: remindTime,
      payload: 'surgery_reminder:$surgeryId',
      channelId: AppConstants.surgeryChannel,
      actions: {
        'view': 'View Details',
        'snooze': 'Snooze 10min',
      },
    );
  }

  /// Schedule overdue surgery notification
  Future<void> scheduleOverdueNotification({
    required String surgeryId,
    required String patientName,
    required String surgeryType,
    required DateTime expectedEndTime,
  }) async {
    final overdueTime = expectedEndTime.add(const Duration(minutes: AppConstants.overdueReminderInterval));
    final overdueDuration = DateTime.now().difference(expectedEndTime);
    final overdueText = _formatDuration(overdueDuration);

    await scheduleNotification(
      id: AppConstants.overdueNotificationId + surgeryId.hashCode,
      title: 'Surgery Running Over Time',
      body: '$patientName - $surgeryType was supposed to end $overdueText ago. Are you still in surgery?',
      scheduledDate: overdueTime,
      payload: 'surgery_overdue:$surgeryId',
      channelId: AppConstants.urgentChannel,
      isUrgent: true,
      actions: {
        'still_in_surgery': 'Still in Surgery',
        'completed': 'Mark Complete',
      },
    );
  }

  /// Schedule check-in reminder
  Future<void> scheduleCheckInReminder() async {
    final reminderTime = DateTime.now().add(const Duration(minutes: AppConstants.checkInReminderInterval));

    await scheduleNotification(
      id: AppConstants.checkInReminderNotificationId,
      title: 'Daily Check-In Reminder',
      body: 'Please check in to mark your availability for today',
      scheduledDate: reminderTime,
      payload: 'check_in_reminder:daily',
      channelId: AppConstants.reminderChannel,
      actions: {
        'check_in': 'Check In Now',
        'snooze': 'Remind Later',
      },
    );
  }

  /// Cancel notification
  Future<void> cancelNotification(int id) async {
    try {
      await _localNotifications.cancel(id);
      print('Cancelled notification: $id');
    } catch (e) {
      print('Error cancelling notification: $e');
    }
  }

  /// Cancel surgery-related notifications
  Future<void> cancelSurgeryNotifications(String surgeryId) async {
    final reminderNotificationId = AppConstants.surgeryReminderNotificationId + surgeryId.hashCode;
    final overdueNotificationId = AppConstants.overdueNotificationId + surgeryId.hashCode;

    await Future.wait([
      cancelNotification(reminderNotificationId),
      cancelNotification(overdueNotificationId),
    ]);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
      print('Cancelled all notifications');
    } catch (e) {
      print('Error cancelling all notifications: $e');
    }
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _localNotifications.pendingNotificationRequests();
    } catch (e) {
      print('Error getting pending notifications: $e');
      return [];
    }
  }

  /// Format duration for display
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      if (minutes > 0) {
        return '${hours}h ${minutes}m';
      } else {
        return '${hours}h';
      }
    } else {
      return '${minutes}m';
    }
  }

  /// Request notification permissions (iOS)
  Future<bool> requestPermissions() async {
    try {
      if (Platform.isIOS) {
        final plugin = _localNotifications
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
        if (plugin != null) {
          final result = await plugin.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
          return result ?? false;
        }
        return false;
      }
      // Android doesn't need runtime permission request for notifications
      return true;
    } catch (e) {
      print('Error requesting notification permissions: $e');
      // Return true as fallback to not block the app
      return true;
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      if (Platform.isAndroid) {
        final androidPlugin = _localNotifications
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        return await androidPlugin?.areNotificationsEnabled() ?? false;
      } else if (Platform.isIOS) {
        // For iOS, assume notifications are enabled if the plugin is available
        // The requestPermissions method should be called separately
        final iosPlugin = _localNotifications
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
        return iosPlugin != null;
      }
      return false;
    } catch (e) {
      print('Error checking notification permissions: $e');
      // Return true as fallback to not block the app
      return true;
    }
  }
}