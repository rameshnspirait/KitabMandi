import 'package:flutter/material.dart';
import 'package:kitab_mandi/features/dashboard/model/book_model.dart';
import 'package:kitab_mandi/widgets/app_cached_image_network.dart';

class ListingGridCard extends StatelessWidget {
  final BookModel book;

  const ListingGridCard({super.key, required this.book});

  Color _surface(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1A1D23) : const Color(0xFFFFFFFF);
  }

  Color _borderColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.transparent : const Color(0xFFE5E7EB);
  }

  Color _mutedText(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFB0B3B8) : const Color(0xFF6B7280);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: _surface(context),
        borderRadius: BorderRadius.circular(16),

        /// ✨ PREMIUM LIGHT SHADOW
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.dark ? 0.25 : 0.06,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],

        border: Border.all(color: _borderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 📸 IMAGE SECTION
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

              /// ❤️ FAVORITE ICON (IMPROVED VISIBILITY)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.favorite_border,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          /// 📄 DETAILS
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 💰 PRICE (more premium hierarchy)
                Text(
                  book.price,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: theme.colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 6),

                /// 📘 TITLE
                Text(
                  book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),

                const SizedBox(height: 10),

                /// 👤 SELLER
                Row(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: theme.colorScheme.primary.withOpacity(
                        0.15,
                      ),
                      child: Icon(
                        Icons.person,
                        size: 12,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 6),

                    Expanded(
                      child: Text(
                        "Published by ${book.sellerName}",
                        style: TextStyle(
                          fontSize: 12,
                          color: _mutedText(context),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                /// 📍 LOCATION + TIME
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 13,
                      color: _mutedText(context),
                    ),
                    const SizedBox(width: 4),

                    Expanded(
                      child: Text(
                        book.location,
                        style: TextStyle(
                          fontSize: 12,
                          color: _mutedText(context),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    Text(
                      "• ${book.postedTime}",
                      style: TextStyle(
                        fontSize: 11,
                        color: _mutedText(context),
                      ),
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
