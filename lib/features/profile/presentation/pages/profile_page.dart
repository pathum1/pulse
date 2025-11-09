import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/surgeon.dart';

/// Profile Page
/// Shows surgeon's profile and settings
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Surgeon? _surgeon; // TODO: Load from Firebase Auth + Firestore
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    // TODO: Load actual surgeon profile from Firestore
    // For now, using mock data for demonstration
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _surgeon = _generateMockSurgeon();
        _isLoading = false;
      });
    });
  }

  Surgeon _generateMockSurgeon() {
    final now = DateTime.now();
    return Surgeon(
      id: 'current_user_id',
      name: 'Dr. Sarah Smith',
      email: 'sarah.smith@hospital.com',
      phone: '+1 (555) 123-4567',
      specialization: 'General Surgery',
      isAvailableToday: true,
      lastCheckIn: now.subtract(const Duration(hours: 2)),
      totalSurgeriesCompleted: 247,
      currentStatus: 'available',
      certifications: const ['Board Certified General Surgeon', 'Laparoscopic Surgery Specialist'],
      createdAt: now.subtract(const Duration(days: 365)),
      updatedAt: now,
      profileImageUrl: null,
      notificationSettings: const {
        'surgeryReminders': true,
        'overdueAlerts': true,
        'checkInReminders': true,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
        actions: [
          if (!_isLoading && _surgeon != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditProfilePage(context),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _surgeon == null
              ? _buildErrorState()
              : _buildProfileContent(),
    );
  }

  Widget _buildErrorState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Unable to load profile',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'Please check your connection and try again',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    final surgeon = _surgeon!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header
          _buildProfileHeader(surgeon),
          const SizedBox(height: 24),
          
          // Stats Section
          _buildStatsSection(surgeon),
          const SizedBox(height: 24),
          
          // Information Section
          _buildInformationSection(surgeon),
          const SizedBox(height: 24),
          
          // Settings Section
          _buildSettingsSection(surgeon),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(Surgeon surgeon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.surgicalTeal.withOpacity(0.1),
              backgroundImage: surgeon.profileImageUrl != null 
                  ? NetworkImage(surgeon.profileImageUrl!)
                  : null,
              child: surgeon.profileImageUrl == null
                  ? const Icon(
                      Icons.person,
                      size: 50,
                      color: AppColors.surgicalTeal,
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              surgeon.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              surgeon.specialization,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(surgeon.currentStatus),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                surgeon.statusDisplayText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(Surgeon surgeon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Surgeries Completed',
                    surgeon.totalSurgeriesCompleted.toString(),
                    Icons.medical_services,
                    AppColors.surgicalTeal,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    'Years of Experience',
                    '${DateTime.now().difference(surgeon.createdAt).inDays ~/ 365}',
                    Icons.star,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInformationSection(Surgeon surgeon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Contact Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _showEditProfilePage(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.email, 'Email', surgeon.email),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.phone, 'Phone', surgeon.phone),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.work, 'Specialization', surgeon.specialization),
            if (surgeon.certifications.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildCertificationsSection(surgeon.certifications),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCertificationsSection(List<String> certifications) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.verified, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Text(
              'Certifications',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...certifications.map((cert) => Padding(
          padding: const EdgeInsets.only(left: 32, bottom: 4),
          child: Row(
            children: [
              const Text('•'),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  cert,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildSettingsSection(Surgeon surgeon) {
    final notificationSettings = surgeon.notificationSettings ?? {};
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notification Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildSwitchTile(
              'Surgery Reminders',
              'Get notified before your surgeries',
              notificationSettings['surgeryReminders'] ?? true,
              (value) {
                // TODO: Update notification settings in Firestore
              },
            ),
            _buildSwitchTile(
              'Overdue Alerts',
              'Get notified when surgeries run over time',
              notificationSettings['overdueAlerts'] ?? true,
              (value) {
                // TODO: Update notification settings in Firestore
              },
            ),
            _buildSwitchTile(
              'Check-in Reminders',
              'Daily availability check-in reminders',
              notificationSettings['checkInReminders'] ?? true,
              (value) {
                // TODO: Update notification settings in Firestore
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      activeColor: AppColors.surgicalTeal,
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'available':
        return Colors.green;
      case 'busy':
        return Colors.orange;
      case 'on_leave':
        return Colors.red;
      case 'in_surgery':
        return AppColors.surgicalTeal;
      default:
        return Colors.grey;
    }
  }

  void _showEditProfilePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(surgeon: _surgeon!),
      ),
    ).then((result) {
      if (result == true) {
        _loadProfile(); // Reload profile if changes were made
      }
    });
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement logout functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logout functionality will be implemented')),
              );
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

/// Edit Profile Page
/// Allows editing of surgeon profile information
class EditProfilePage extends StatefulWidget {
  final Surgeon surgeon;

  const EditProfilePage({super.key, required this.surgeon});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _specializationController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.surgeon.name);
    _phoneController = TextEditingController(text: widget.surgeon.phone);
    _specializationController = TextEditingController(text: widget.surgeon.specialization);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _specializationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveChanges,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture Section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.surgicalTeal.withOpacity(0.1),
                      backgroundImage: widget.surgeon.profileImageUrl != null 
                          ? NetworkImage(widget.surgeon.profileImageUrl!)
                          : null,
                      child: widget.surgeon.profileImageUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 50,
                              color: AppColors.surgicalTeal,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.surgicalTeal,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, size: 18),
                          color: Colors.white,
                          onPressed: () {
                            // TODO: Implement image picker
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Image upload will be implemented')),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Form Fields
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _specializationController,
                decoration: const InputDecoration(
                  labelText: 'Specialization',
                  prefixIcon: Icon(Icons.work),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your specialization';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email (Read-only)
              TextFormField(
                initialValue: widget.surgeon.email,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  suffixIcon: Icon(Icons.lock, size: 16),
                ),
                enabled: false,
              ),
              const SizedBox(height: 8),
              Text(
                'Email cannot be changed. Contact administrator if needed.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        // TODO: Save changes to Firestore
        await Future.delayed(const Duration(seconds: 1)); // Simulate API call
        
        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate changes were made
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update profile')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}