import 'package:flutter/material.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/features/dashboard/model/book_model.dart';
import 'package:kitab_mandi/widgets/app_cached_image_network.dart';

class ListingGridCard extends StatelessWidget {
  final BookModel book;

  const ListingGridCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// IMAGE
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: AppCachedImageNetwork(
                  imageUrl: book.imageUrl,
                  height: 130,
                  width: double.infinity,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
              ),

              Positioned(
                top: 8,
                right: 8,
                child: const Icon(Icons.favorite_border, color: Colors.white),
              ),
            ],
          ),

          /// DETAILS
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.price,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: theme.colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis),

                const SizedBox(height: 6),

                Row(
                  children: [
                    const CircleAvatar(
                      radius: 10,
                      child: Icon(
                        Icons.person,
                        size: 10,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Published by ${book.sellerName}",
                        style: TextStyle(fontSize: 11, color: theme.hintColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Icon(Icons.location_on, size: 12, color: theme.hintColor),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        book.location,
                        style: TextStyle(fontSize: 11, color: theme.hintColor),
                      ),
                    ),
                    Text(
                      " • ${book.postedTime}",
                      style: TextStyle(fontSize: 11, color: theme.hintColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
