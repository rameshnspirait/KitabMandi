import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/features/dashboard/controller/home_controller.dart';
import 'package:kitab_mandi/features/dashboard/widget/home_listing_card_shimmer.dart';
import 'package:kitab_mandi/features/dashboard/widget/home_listing_card_widget.dart';
import 'package:kitab_mandi/features/dashboard/widget/home_location_appbar_widget.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final homeCtrl = Get.put(HomeController());

  @override
  void initState() {
    super.initState();

    // 🔥 IMPORTANT → use real-time listener
    homeCtrl.listenListings();
  }

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

        // 🔥 MAIN FIX → OBX
        child: Obx(() {
          /// 🔥 LOADING STATE
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

          /// 🔥 EMPTY STATE
          if (homeCtrl.listings.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 150),
                Center(
                  child: Text(
                    "No listings found 😔",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
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
