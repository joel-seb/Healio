import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'user_data.dart';
import 'edit_profile.dart';
import 'login.dart';

class ProfileScreen extends StatefulWidget {
  final UserData userData;

  const ProfileScreen({super.key, required this.userData});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserData currentUserData;

  @override
  void initState() {
    super.initState();
    currentUserData = widget.userData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + edit button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.displaySmall?.color,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Color(0xFF20B2AA)),
                    onPressed: () async {
                      final updatedData = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(userData: currentUserData),
                        ),
                      );
                      if (updatedData != null) {
                        setState(() => currentUserData = updatedData);
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Avatar + name + email — horizontal card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color ?? Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF20B2AA).withOpacity(0.12),
                        border: Border.all(color: const Color(0xFF20B2AA), width: 2),
                      ),
                      child: Center(
                        child: Text(
                          currentUserData.name.isNotEmpty
                              ? currentUserData.name.trim().split(' ')
                                  .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
                                  .take(2).join()
                              : '?',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF20B2AA),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentUserData.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.displaySmall?.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentUserData.email,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Health Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.headlineMedium?.color,
                ),
              ),

              const SizedBox(height: 12),

              // 2x2 grid using Expanded rows to fill remaining space
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: _buildHealthInfoCard(
                            icon: Icons.favorite,
                            iconColor: const Color(0xFFE57373),
                            label: 'Blood Type',
                            value: currentUserData.bloodType,
                          )),
                          const SizedBox(width: 16),
                          Expanded(child: _buildHealthInfoCard(
                            icon: Icons.calendar_today,
                            iconColor: const Color(0xFF20B2AA),
                            label: 'Age',
                            value: '${currentUserData.age} years',
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: _buildHealthInfoCard(
                            icon: Icons.height,
                            iconColor: const Color(0xFF64B5F6),
                            label: 'Height',
                            value: '${currentUserData.height.toStringAsFixed(0)} cm',
                          )),
                          const SizedBox(width: 16),
                          Expanded(child: _buildHealthInfoCard(
                            icon: Icons.fitness_center,
                            iconColor: const Color(0xFFFFB74D),
                            label: 'Weight',
                            value: '${currentUserData.weight.toStringAsFixed(1)} kg',
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSettingsOption(
                      icon: Icons.logout,
                      title: 'Logout',
                      titleColor: Colors.red,
                      iconColor: Colors.red,
                      onTap: _showLogoutDialog,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthInfoCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.headlineMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsOption({
    required IconData icon,
    required String title,
    Color? titleColor,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: iconColor ?? const Color(0xFF20B2AA), size: 22),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: titleColor ?? Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    color: Theme.of(context).textTheme.bodyMedium?.color, size: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    final outerContext = context;
    showDialog(
      context: outerContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await AuthService().logout();
              if (!mounted) return;
              Navigator.of(outerContext).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const Login()),
                (route) => false,
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
