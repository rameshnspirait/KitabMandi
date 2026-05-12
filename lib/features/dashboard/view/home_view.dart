import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/features/dashboard/controller/home_controller.dart';
import 'package:kitab_mandi/features/dashboard/widget/home_listing_card_shimmer.dart';
import 'package:kitab_mandi/features/dashboard/widget/home_listing_card_widget.dart';
import 'package:kitab_mandi/features/dashboard/widget/home_location_appbar_widget.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final homeCtrl = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const LocationAppBar(),

      body: RefreshIndicator(
        onRefresh: () async {
          await homeCtrl.fetchListings();
        },

        //  MAIN FIX → OBX
        child: Obx(() {
          ///  LOADING STATE
          if (homeCtrl.isLoading.value) {
            return MasonryGridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: 6,
              itemBuilder: (_, __) => const ListingGridCardShimmer(),
            );
          }

          ///  EMPTY STATE
          if (homeCtrl.listings.isEmpty) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(), // ✅ required
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            constraints.maxHeight, // 👈 full screen height
                      ),
                      child: const Center(
                        child: Text(
                          "No listings found 😔",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }

          ///  DATA STATE
          return MasonryGridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: homeCtrl.listings.length,
            itemBuilder: (context, index) {
              final book = homeCtrl.listings[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ListingGridCard(book: book),
              );
            },
          );
        }),
      ),
    );
  }
}
