import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

/// Check-In Page
/// Daily availability check-in for surgeons
class CheckInPage extends StatefulWidget {
  const CheckInPage({super.key});

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  bool? _selectedAvailability;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Check-In'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.access_time,
              size: 80,
              color: AppColors.surgicalTeal,
            ),
            const SizedBox(height: 24),
            const Text(
              'Are you available for surgeries today?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            Row(
              children: [
                Expanded(
                  child: _AvailabilityButton(
                    isSelected: _selectedAvailability == true,
                    onPressed: () {
                      setState(() {
                        _selectedAvailability = true;
                      });
                    },
                    text: 'Yes, Available',
                    selectedColor: AppColors.surgicalTeal,
                    icon: Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _AvailabilityButton(
                    isSelected: _selectedAvailability == false,
                    onPressed: () {
                      setState(() {
                        _selectedAvailability = false;
                      });
                    },
                    text: 'No, On Leave',
                    selectedColor: AppColors.warmCoral,
                    icon: Icons.cancel,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _selectedAvailability != null ? () {
                // TODO: Save check-in status to Firestore with timestamp
                // TODO: Store locally to prevent multiple check-ins
                context.go('/calendar');
              } : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                backgroundColor: _selectedAvailability != null 
                    ? AppColors.surgicalTeal 
                    : Colors.grey.shade300,
              ),
              child: Text(
                'Check In',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _selectedAvailability != null 
                      ? Colors.white 
                      : Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom availability selection button with enhanced visual feedback
class _AvailabilityButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onPressed;
  final String text;
  final Color selectedColor;
  final IconData icon;

  const _AvailabilityButton({
    required this.isSelected,
    required this.onPressed,
    required this.text,
    required this.selectedColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? selectedColor : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isSelected 
            ? selectedColor.withOpacity(0.1) 
            : Colors.transparent,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: isSelected ? selectedColor : Colors.grey.shade400,
                ),
                const SizedBox(height: 8),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? selectedColor : Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (isSelected) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: 20,
                    height: 3,
                    decoration: BoxDecoration(
                      color: selectedColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}