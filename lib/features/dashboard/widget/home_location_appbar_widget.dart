import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/controller/location_controller.dart';

class LocationAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LocationAppBar({super.key});

  Color _background(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1A1D23) : const Color(0xFFFFFFFF);
  }

  Color _border(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.transparent : const Color(0xFFE5E7EB);
  }

  Color _mutedText(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFB0B3B8) : const Color(0xFF6B7280);
  }

  void _openLocationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _LocationSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<LocationController>();

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: _background(context),
      shape: Border(bottom: BorderSide(color: _border(context), width: 1)),
      titleSpacing: 12,

      title: Row(
        children: [
          Icon(Icons.location_on, color: theme.colorScheme.primary, size: 20),

          const SizedBox(width: 8),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Deliver to",
                style: TextStyle(fontSize: 11, color: _mutedText(context)),
              ),

              Obx(
                () => GestureDetector(
                  onTap: () => _openLocationSheet(context),
                  child: Row(
                    children: [
                      Text(
                        controller.selectedLocation.value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 18,
                        color: theme.iconTheme.color,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),

      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.notifications_none, color: theme.iconTheme.color),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/* -------------------------- LOCATION SHEET -------------------------- */

class _LocationSheet extends StatefulWidget {
  const _LocationSheet();

  @override
  State<_LocationSheet> createState() => _LocationSheetState();
}

class _LocationSheetState extends State<_LocationSheet> {
  final TextEditingController searchController = TextEditingController();

  final List<String> allCities = [
    "Vijayawada",
    "Hyderabad",
    "Bangalore",
    "Chennai",
    "Delhi",
    "Mumbai",
    "Pune",
    "Kolkata",
  ];

  String query = "";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<LocationController>();

    List<String> filtered = allCities
        .where((e) => e.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),

              /// HANDLE BAR
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 12),

              /// HEADER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Spacer(),
                    Text(
                      "Select City",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              /// SEARCH BAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: searchController,
                  onChanged: (v) => setState(() => query = v),
                  decoration: InputDecoration(
                    hintText: "Search city...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /// CURRENT LOCATION
              Obx(() {
                final controller = Get.find<LocationController>();

                return ListTile(
                  leading: controller.isLoadingLocation.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          Icons.my_location,
                          color: Theme.of(context).colorScheme.primary,
                        ),

                  title: Text(
                    controller.isLoadingLocation.value
                        ? "Detecting location..."
                        : "Use current location",
                  ),

                  onTap: () async {
                    await controller.detectCurrentLocation();
                    Get.back();
                  },
                );
              }),

              const Divider(),

              /// LIST
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Cities",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: theme.hintColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    ...filtered.map((city) {
                      final isSelected =
                          controller.selectedLocation.value == city;

                      return ListTile(
                        leading: Icon(
                          Icons.location_city,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.iconTheme.color,
                        ),

                        title: Text(city),

                        trailing: isSelected
                            ? Icon(
                                Icons.check,
                                color: theme.colorScheme.primary,
                              )
                            : null,

                        onTap: () {
                          controller.updateLocation(city);
                          Get.back();
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
