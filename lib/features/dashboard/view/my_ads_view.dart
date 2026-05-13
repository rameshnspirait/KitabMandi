import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/features/dashboard/controller/my_ads_controller.dart';
import 'package:kitab_mandi/features/dashboard/model/listing_model.dart';

class MyAdsView extends StatelessWidget {
  MyAdsView({super.key});
  final controller = Get.put(MyAdsController());
  Color _background(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1A1D23) : const Color(0xFFFFFFFF);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("My Ads"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: _background(context),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.myAdsList.isEmpty) {
          return _emptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.myAdsList.length,
          itemBuilder: (context, index) {
            final ad = controller.myAdsList[index];
            return _adCard(ad, controller);
          },
        );
      }),
    );
  }

  // ================= EMPTY STATE =================
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.campaign_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            "No Ads Yet",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text("Start selling your books now!"),
        ],
      ),
    );
  }

  // ================= AD CARD =================
  Widget _adCard(ListingModel ad, MyAdsController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          // 📸 IMAGE
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              bottomLeft: Radius.circular(14),
            ),
            child: Image.network(
              ad.images[0],
              height: 100,
              width: 100,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 100,
                width: 100,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),

          // 📄 DETAILS
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    ad.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Price
                  Text(
                    "₹ ${ad.price}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Status
                  Row(
                    children: [
                      Icon(
                        ad.isSold != null
                            ? Icons.check_circle
                            : Icons.radio_button_checked,
                        size: 14,
                        color: ad.isSold != null ? Colors.red : Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ad.isSold != null ? "Sold" : "Active",
                        style: TextStyle(
                          fontSize: 12,
                          color: ad.isSold != null ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ACTION BUTTONS
                  Row(
                    children: [
                      _actionButton(
                        icon: Icons.edit,
                        label: "Edit",
                        color: Colors.blue,
                        onTap: () => controller.editAd(ad),
                      ),
                      const SizedBox(width: 8),
                      _actionButton(
                        icon: Icons.delete,
                        label: "Delete",
                        color: Colors.red,
                        onTap: () => controller.deleteAd(ad.id),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= BUTTON =================
  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
