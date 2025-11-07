import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

/// Onboarding Page
/// Introduces users to Pulse Track features and benefits
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _onboardingItems = [
    OnboardingItem(
      icon: Icons.schedule,
      title: 'Manage Your Surgery Schedule',
      description: 'Keep track of all your scheduled surgeries in one place. View your daily schedule with start and end times.',
      color: AppColors.surgicalTeal,
    ),
    OnboardingItem(
      icon: Icons.notifications_active,
      title: 'Never Miss a Surgery',
      description: 'Get reliable notifications for upcoming surgeries and automatic reminders when procedures run overtime.',
      color: AppColors.deepIndigo,
    ),
    OnboardingItem(
      icon: Icons.people,
      title: 'Hospital-Wide Visibility',
      description: 'See who\'s available and what surgeries are happening across the hospital with the central calendar view.',
      color: AppColors.warmCoral,
    ),
    OnboardingItem(
      icon: Icons.check_circle,
      title: 'Daily Check-In System',
      description: 'Mark your availability each day and let colleagues know when you\'re in surgery or available for new procedures.',
      color: AppColors.surgicalTeal,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _onboardingItems.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _completeOnboarding() {
    // Mark onboarding as completed
    // This would typically save to local storage
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark 
          ? AppColors.darkBackground 
          : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: isDark 
                          ? AppColors.darkSecondaryText 
                          : AppColors.lightSecondaryText,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            
            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingItems.length,
                itemBuilder: (context, index) {
                  return _OnboardingItemWidget(
                    item: _onboardingItems[index],
                    isDark: isDark,
                  );
                },
              ),
            ),
            
            // Page indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _onboardingItems.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? AppColors.surgicalTeal
                          : (isDark 
                              ? AppColors.darkDivider 
                              : AppColors.lightDivider),
                    ),
                  ),
                ),
              ),
            ),
            
            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surgicalTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _currentPage == _onboardingItems.length - 1
                        ? 'Get Started'
                        : 'Next',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual onboarding item widget
class _OnboardingItemWidget extends StatelessWidget {
  final OnboardingItem item;
  final bool isDark;
  
  const _OnboardingItemWidget({
    required this.item,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: item.color.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              item.icon,
              size: 60,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Title
          Text(
            item.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark 
                  ? AppColors.darkPrimaryText 
                  : AppColors.lightPrimaryText,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Description
          Text(
            item.description,
            style: TextStyle(
              fontSize: 16,
              color: isDark 
                  ? AppColors.darkSecondaryText 
                  : AppColors.lightSecondaryText,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Onboarding item model
class OnboardingItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  
  OnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}