import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

/// Profile Setup Page
/// Mandatory profile setup after first login for surgeons
class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  
  // Controllers for form fields
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _specialityController = TextEditingController();
  final _hospitalIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  
  int _currentStep = 0;
  final int _totalSteps = 3;
  bool _isLoading = false;
  
  // Profile data
  String _selectedTitle = 'Dr.';
  final List<String> _selectedSpecializations = [];
  String _selectedAvailability = 'Full-time';
  bool _acceptNotifications = true;

  final List<String> _titles = ['Dr.', 'Prof.', 'Mr.', 'Ms.', 'Mrs.'];
  
  final List<String> _specializations = [
    'General Surgery',
    'Cardiovascular Surgery',
    'Neurosurgery',
    'Orthopedic Surgery',
    'Plastic Surgery',
    'Urological Surgery',
    'Gynecological Surgery',
    'Thoracic Surgery',
    'Pediatric Surgery',
    'Emergency Surgery',
  ];

  final List<String> _availabilityOptions = [
    'Full-time',
    'Part-time',
    'On-call only',
    'Consultations only',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _specialityController.dispose();
    _hospitalIdController.dispose();
    _phoneController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      if (_validateCurrentStep()) {
        setState(() {
          _currentStep++;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      _completeSetup();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _firstNameController.text.isNotEmpty && 
               _lastNameController.text.isNotEmpty &&
               _hospitalIdController.text.isNotEmpty;
      case 1:
        return _selectedSpecializations.isNotEmpty;
      case 2:
        return _phoneController.text.isNotEmpty;
      default:
        return false;
    }
  }

  void _completeSetup() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      // TODO: Save profile data to Firestore
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          // Mark profile as completed and navigate to main app
          context.go('/calendar');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _currentStep > 0 ? _previousStep : null,
            child: Text(
              'Back',
              style: TextStyle(
                color: _currentStep > 0 ? AppColors.surgicalTeal : Colors.grey,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: List.generate(_totalSteps, (index) {
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(right: index < _totalSteps - 1 ? 8 : 0),
                        decoration: BoxDecoration(
                          color: index <= _currentStep 
                              ? AppColors.surgicalTeal 
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                Text(
                  'Step ${_currentStep + 1} of $_totalSteps',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildPersonalInfoStep(),
                  _buildSpecializationStep(),
                  _buildContactStep(),
                ],
              ),
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surgicalTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(_currentStep == _totalSteps - 1 ? 'Complete Setup' : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Let\'s start with your basic information',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),

          // Title dropdown
          DropdownButtonFormField<String>(
            value: _selectedTitle,
            decoration: const InputDecoration(
              labelText: 'Title*',
              prefixIcon: Icon(Icons.person),
            ),
            items: _titles.map((title) {
              return DropdownMenuItem(value: title, child: Text(title));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedTitle = value!;
              });
            },
          ),
          const SizedBox(height: 16),

          // First Name
          TextFormField(
            controller: _firstNameController,
            decoration: const InputDecoration(
              labelText: 'First Name*',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter your first name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Last Name
          TextFormField(
            controller: _lastNameController,
            decoration: const InputDecoration(
              labelText: 'Last Name*',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter your last name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Hospital ID
          TextFormField(
            controller: _hospitalIdController,
            decoration: const InputDecoration(
              labelText: 'Hospital ID*',
              hintText: 'Your hospital staff ID',
              prefixIcon: Icon(Icons.badge),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter your hospital ID';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSpecializationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Specializations',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select your surgical specializations',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),

          // Specializations
          const Text(
            'Areas of Expertise (Select all that apply)*',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _specializations.map((spec) {
              final isSelected = _selectedSpecializations.contains(spec);
              return FilterChip(
                label: Text(spec),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedSpecializations.add(spec);
                    } else {
                      _selectedSpecializations.remove(spec);
                    }
                  });
                },
                selectedColor: AppColors.surgicalTeal.withOpacity(0.2),
                checkmarkColor: AppColors.surgicalTeal,
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Availability
          DropdownButtonFormField<String>(
            value: _selectedAvailability,
            decoration: const InputDecoration(
              labelText: 'Availability Status*',
              prefixIcon: Icon(Icons.schedule),
            ),
            items: _availabilityOptions.map((availability) {
              return DropdownMenuItem(value: availability, child: Text(availability));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedAvailability = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'How can colleagues reach you?',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),

          // Phone
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Mobile Phone*',
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter your mobile phone';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Emergency Contact
          TextFormField(
            controller: _emergencyContactController,
            decoration: const InputDecoration(
              labelText: 'Emergency Contact (Optional)',
              hintText: 'Colleague or department phone',
              prefixIcon: Icon(Icons.contact_phone),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),

          // Notification preferences
          SwitchListTile(
            title: const Text('Accept Push Notifications'),
            subtitle: const Text('Receive surgery reminders and updates'),
            value: _acceptNotifications,
            activeColor: AppColors.surgicalTeal,
            onChanged: (value) {
              setState(() {
                _acceptNotifications = value;
              });
            },
          ),
          const SizedBox(height: 24),

          // Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surgicalTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profile Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text('Name: $_selectedTitle ${_firstNameController.text} ${_lastNameController.text}'),
                const SizedBox(height: 4),
                Text('Hospital ID: ${_hospitalIdController.text}'),
                const SizedBox(height: 4),
                Text('Specializations: ${_selectedSpecializations.join(", ")}'),
                const SizedBox(height: 4),
                Text('Availability: $_selectedAvailability'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}