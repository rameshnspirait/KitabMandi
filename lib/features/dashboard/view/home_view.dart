import 'package:flutter/material.dart';
import 'package:kitab_mandi/features/dashboard/data/dummy.dart';
import 'package:kitab_mandi/features/dashboard/widget/home_listing_card_shimmer.dart';
import 'package:kitab_mandi/features/dashboard/widget/home_listing_card_widget.dart';
import 'package:kitab_mandi/features/dashboard/widget/home_location_appbar_widget.dart';
import 'package:kitab_mandi/features/dashboard/widget/home_searchbar_widget.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    final aspectRatio = width < 360
        ? 0.55
        : width < 420
        ? 0.60
        : 0.65;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const LocationAppBar(),

      body: Column(
        children: [
          const SizedBox(height: 10),
          SearchBarWidget(
            controller: TextEditingController(),
            onChanged: (value) {},
            onFilterTap: () {},
          ),
          const SizedBox(height: 10),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(Duration(seconds: 2));
              },
              child: isLoading
                  ? GridView.builder(
                      itemCount: 6,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.68,
                          ),
                      itemBuilder: (_, __) => const ListingGridCardShimmer(),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: dummyBooks.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: aspectRatio,
                      ),
                      itemBuilder: (context, index) {
                        final book = dummyBooks[index];

                        return ListingGridCard(book: book);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
