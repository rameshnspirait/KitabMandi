import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_text_style.dart';
import 'package:kitab_mandi/core/controller/theme_controller.dart';
import 'package:kitab_mandi/widgets/app_button.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  Color _background(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1A1D23) : const Color(0xFFFFFFFF);
  }

  Color _surface(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1A1D23) : const Color(0xFFFFFFFF);
  }

  Color _softSurface(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF151821) : const Color(0xFFF9FAFB);
  }

  Border _border(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Border.all(
      color: isDark ? Colors.transparent : const Color(0xFFE5E7EB),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<ThemeController>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Profile", style: AppTextStyles.heading2(context)),
        elevation: 0,
        backgroundColor: _background(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// PROFILE HEADER
            _buildProfileHeader(context),
            const SizedBox(height: 20),

            ///  STATS
            _buildStats(context),
            const SizedBox(height: 20),

            /// ⚡ QUICK ACTIONS
            _buildQuickActions(context),
            const SizedBox(height: 20),

            /// THEME SWITCH
            Obx(() => _themeSwitch(context, controller)),
            const SizedBox(height: 20),

            ///  ACCOUNT
            _buildSection(
              context,
              title: "Account",
              children: [
                _tile(context, Icons.person_outline, "Edit Profile"),
                _tile(context, Icons.book_outlined, "My Listings"),
                _tile(context, Icons.shopping_bag_outlined, "My Orders"),
                _tile(context, Icons.favorite_border, "Wishlist"),
              ],
            ),

            const SizedBox(height: 20),

            ///  SUPPORT
            _buildSection(
              context,
              title: "Support",
              children: [
                _tile(context, Icons.help_outline, "Help Center"),
                _tile(context, Icons.policy_outlined, "Terms & Policies"),
                _tile(context, Icons.info_outline, "About App"),
              ],
            ),

            const SizedBox(height: 20),

            ///  LOGOUT
            _logoutButton(context),
          ],
        ),
      ),
    );
  }

  ///  PROFILE HEADER
  Widget _buildProfileHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface(context),
        borderRadius: BorderRadius.circular(20),
        border: _border(context),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            child: Icon(
              Icons.person,
              size: 32,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Ramesh", style: AppTextStyles.title(context)),
                const SizedBox(height: 4),
                Text("ramesh@email.com", style: AppTextStyles.caption(context)),
              ],
            ),
          ),

          Icon(Icons.edit, color: theme.iconTheme.color),
        ],
      ),
    );
  }

  ///  STATS
  Widget _buildStats(BuildContext context) {
    return Row(
      children: [
        _statItem(context, "12", "Listings"),
        _statItem(context, "8", "Sold"),
        _statItem(context, "5", "Bought"),
      ],
    );
  }

  Widget _statItem(BuildContext context, String count, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _softSurface(context),
          borderRadius: BorderRadius.circular(16),
          border: _border(context),
        ),
        child: Column(
          children: [
            Text(count, style: AppTextStyles.title(context)),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.caption(context)),
          ],
        ),
      ),
    );
  }

  ///  QUICK ACTIONS
  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        _action(context, Icons.add_circle_outline, "Sell"),
        _action(context, Icons.list_alt_outlined, "My Ads"),
        _action(context, Icons.favorite_border, "Wishlist"),
        _action(context, Icons.chat_bubble_outline, "Chat"),
      ],
    );
  }

  Widget _action(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 6),
          Text(label, style: AppTextStyles.caption(context)),
        ],
      ),
    );
  }

  ///  THEME SWITCH
  Widget _themeSwitch(BuildContext context, ThemeController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text("Dark Mode", style: AppTextStyles.body(context)),

        value: controller.isDarkMode(context),

        onChanged: controller.toggleTheme,
      ),
    );
  }

  /// 📂 SECTION
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface(context),
        borderRadius: BorderRadius.circular(16),
        border: _border(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.subtitle(context)),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  /// 🔹 TILE (PREMIUM CARD STYLE)
  Widget _tile(BuildContext context, IconData icon, String title) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: _surface(context),
        borderRadius: BorderRadius.circular(12),
        border: _border(context),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: Icon(icon, color: theme.iconTheme.color),
        title: Text(title, style: AppTextStyles.body(context)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () {},
      ),
    );
  }

  /// 🚪 LOGOUT
  Widget _logoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AppButton(text: 'Logout', onPressed: () {}),
      // ElevatedButton(
      //   style: ElevatedButton.styleFrom(
      //     backgroundColor: AppColors.primaryDark, // softer but richer red tint

      //     foregroundColor: const Color(0xFFE53935), // stronger red text
      //     elevation: 0,
      //   ),
      //   onPressed: () {},
      //   child: Text("Logout", style: AppTextStyles.button(context)),
      // ),
    );
  }
}
