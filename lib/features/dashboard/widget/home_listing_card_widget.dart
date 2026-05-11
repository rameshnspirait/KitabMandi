import 'package:flutter/material.dart';
import 'package:kitab_mandi/core/utils/time_ago_utils.dart';
import 'package:kitab_mandi/features/dashboard/model/listing_model.dart';
import 'package:kitab_mandi/widgets/app_cached_image_network.dart';

class ListingGridCard extends StatefulWidget {
  final ListingModel book;

  const ListingGridCard({super.key, required this.book});

  @override
  State<ListingGridCard> createState() => _ListingGridCardState();
}

class _ListingGridCardState extends State<ListingGridCard> {
  bool isFav = false;
  int currentImage = 0;

  Color _surface(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1A1D23) : Colors.white;
  }

  void _toggleFav() {
    setState(() => isFav = !isFav);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            color: _surface(context),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  theme.brightness == Brightness.dark ? 0.25 : 0.08,
                ),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ================= IMAGE CAROUSEL =================
              Stack(
                children: [
                  SizedBox(
                    height: 140,
                    child: PageView.builder(
                      itemCount: widget.book.images.length,
                      onPageChanged: (i) {
                        setState(() => currentImage = i);
                      },
                      itemBuilder: (_, i) {
                        return Hero(
                          tag: widget.book.id,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(18),
                            ),
                            child: AppCachedImageNetwork(
                              imageUrl: widget.book.images[i],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  /// BOOSTED BADGE
                  if (widget.book.isBoosted ?? false)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "BOOSTED",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                  /// FAVORITE BUTTON ❤️
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: _toggleFav,
                      child: AnimatedScale(
                        scale: isFav ? 1.2 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.black.withOpacity(0.5) // dark mode bg
                                : Colors.white.withOpacity(
                                    0.9,
                                  ), // light mode bg
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav
                                ? Colors.red
                                : Theme.of(context).brightness ==
                                      Brightness.dark
                                ? Colors
                                      .white // visible on dark
                                : Colors.black87, // visible on light
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),

                  /// DOT INDICATOR
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.book.images.length,
                        (i) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: currentImage == i ? 8 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: currentImage == i
                                ? Colors.white
                                : Colors.white54,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              /// ================= DETAILS =================
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// PRICE
                    Text(
                      '₹ ' + widget.book.price.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),

                    const SizedBox(height: 4),

                    /// TITLE (SAFE RESPONSIVE)
                    Text(
                      widget.book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),

                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.person, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Published By ' +
                                widget.book.seller['name'].toString().split(
                                  ' ',
                                )[0],
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    /// LOCATION + TIME
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            getDisplayLocation(widget.book.location),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        Text(
                          TimeAgoUtil.timeAgo(widget.book.createdAt),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getDisplayLocation(Map<String, dynamic> location) {
    final subLocality = location['subLocality'] ?? "";
    final locality = location['locality'] ?? "";
    final city = location['city'] ?? "";

    if (subLocality.isNotEmpty && locality.isNotEmpty) {
      return "$subLocality, $locality";
    } else if (locality.isNotEmpty) {
      return locality;
    } else {
      return city;
    }
  }
}
