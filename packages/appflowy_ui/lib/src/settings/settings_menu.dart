import 'package:flutter/material.dart';

/// Settings page enum for navigation
enum SettingsPage {
  theme,
  language,
  data,
  cloud,
  account,
  notification,
}

/// Settings menu widget - left sidebar navigation
/// Uses standard Flutter theme for better compatibility
class SettingsMenu extends StatelessWidget {
  const SettingsMenu({
    super.key,
    required this.currentPage,
    required this.onPageChanged,
  });

  final SettingsPage currentPage;
  final void Function(SettingsPage) onPageChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF5F5F5),
        borderRadius: const BorderRadius.horizontal(
          left: Radius.circular(12),
        ),
      ),
      height: double.infinity,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            _buildMenuItem(
              context,
              page: SettingsPage.theme,
              label: 'Theme',
              icon: Icons.palette_outlined,
              primaryColor: primaryColor,
            ),
            _buildMenuItem(
              context,
              page: SettingsPage.language,
              label: 'Language',
              icon: Icons.language_outlined,
              primaryColor: primaryColor,
            ),
            _buildMenuItem(
              context,
              page: SettingsPage.data,
              label: 'Data',
              icon: Icons.storage_outlined,
              primaryColor: primaryColor,
            ),
            _buildMenuItem(
              context,
              page: SettingsPage.cloud,
              label: 'Cloud',
              icon: Icons.cloud_outlined,
              primaryColor: primaryColor,
            ),
            _buildMenuItem(
              context,
              page: SettingsPage.account,
              label: 'Account',
              icon: Icons.person_outlined,
              primaryColor: primaryColor,
            ),
            _buildMenuItem(
              context,
              page: SettingsPage.notification,
              label: 'Notification',
              icon: Icons.notifications_outlined,
              primaryColor: primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required SettingsPage page,
    required String label,
    required IconData icon,
    required Color primaryColor,
  }) {
    final isSelected = currentPage == page;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => onPageChanged(page),
          hoverColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryColor.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(color: primaryColor.withOpacity(0.3), width: 1)
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? primaryColor
                      : (isDark ? Colors.white70 : Colors.black54),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? primaryColor
                        : (isDark ? Colors.white70 : Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
