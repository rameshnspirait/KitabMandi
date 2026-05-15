import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/features/dashboard/controller/chat_controller.dart';

class ChatView extends StatelessWidget {
  final controller = Get.put(ChatController());
  ChatView({super.key});

  Color _background(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1A1D23) : const Color(0xFFFFFFFF);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: _background(context),
          title: const Text("Chats"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Buying"),
              Tab(text: "Selling"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [BuyingProductsView(), SellingProductsView()],
        ),
      ),
    );
  }
}

class BuyingProductsView extends StatelessWidget {
  const BuyingProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatController>();
    final theme = Theme.of(context);

    return StreamBuilder<QuerySnapshot>(
      stream: controller.getBuyingProducts(),
      builder: (context, snapshot) {
        /// 🔄 LOADING STATE (initial)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        /// ❌ ERROR STATE
        if (snapshot.hasError) {
          return _stateWidget(
            icon: Icons.error_outline,
            text: "Something went wrong",
          );
        }

        /// 🔥 IGNORE CACHE (IMPORTANT FIX)
        // if (snapshot.hasData && snapshot.data!.metadata.isFromCache) {
        //   return const Center(child: CircularProgressIndicator());
        // }

        /// 📦 DATA
        final docs = snapshot.data?.docs ?? [];

        /// 😔 EMPTY STATE
        if (docs.isEmpty) {
          return _stateWidget(
            icon: Icons.shopping_bag_outlined,
            text: "No products yet",
          );
        }

        /// 🔁 GROUP BY listingId
        final Map<String, List<Map<String, dynamic>>> grouped = {};

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final id = data['listingId'];

          if (id == null) continue;

          grouped.putIfAbsent(id, () => []);
          grouped[id]!.add(data);
        }

        final products = grouped.values.toList();

        /// 🧾 LIST
        return ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final item = products[index].first;
            final count = products[index].length;

            return InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Get.to(
                  () => UsersListView(
                    listingId: item['listingId'],
                    title: item['listingTitle'],
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.08),
                  ),
                ),
                child: Row(
                  children: [
                    /// 🖼 IMAGE
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        item['listingImage'] ?? "",
                        height: 90,
                        width: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 90,
                          width: 90,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image_not_supported),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// 📄 DETAILS
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['listingTitle'] ?? "",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            "₹ ${item['price'] ?? "0"}",
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Row(
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 14,
                                color: theme.hintColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "$count Leads",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.hintColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: theme.hintColor,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _stateWidget({required IconData icon, required String text}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: Colors.grey),
          const SizedBox(height: 12),
          Text(text, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class SellingProductsView extends StatelessWidget {
  const SellingProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatController>();
    final theme = Theme.of(context);

    return StreamBuilder<QuerySnapshot>(
      stream: controller.getSellingProducts(),
      builder: (context, snapshot) {
        /// 🔄 LOADING
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        ///  ERROR
        if (snapshot.hasError) {
          return _stateWidget(
            icon: Icons.error_outline,
            text: "Something went wrong",
          );
        }

        /// 🔥 IGNORE CACHE
        // if (snapshot.hasData && snapshot.data!.metadata.isFromCache) {
        //   return const Center(child: CircularProgressIndicator());
        // }

        final docs = snapshot.data?.docs ?? [];

        /// 😔 EMPTY
        if (docs.isEmpty) {
          return _stateWidget(
            icon: Icons.inventory_2_outlined,
            text: "No buyers yet",
          );
        }

        /// 🔁 GROUP
        final Map<String, List<Map<String, dynamic>>> grouped = {};

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final id = data['listingId'];

          if (id == null) continue;

          grouped.putIfAbsent(id, () => []);
          grouped[id]!.add(data);
        }

        final products = grouped.values.toList();

        return ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final item = products[index].first;
            final count = products[index].length;

            return InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Get.to(
                  () => UsersListView(
                    listingId: item['listingId'],
                    title: item['listingTitle'],
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.08),
                  ),
                ),
                child: Row(
                  children: [
                    /// IMAGE
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        item['listingImage'] ?? "",
                        height: 90,
                        width: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 90,
                          width: 90,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image_not_supported),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// DETAILS
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['listingTitle'] ?? "",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            "₹ ${item['price'] ?? "0"}",
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Row(
                            children: [
                              Icon(
                                Icons.people_alt_outlined,
                                size: 14,
                                color: theme.hintColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "$count interested",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.hintColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: theme.hintColor,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _stateWidget({required IconData icon, required String text}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: Colors.grey),
          const SizedBox(height: 12),
          Text(text, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class UsersListView extends StatelessWidget {
  final String listingId;
  final String title;

  const UsersListView({
    super.key,
    required this.listingId,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatController>();
    final theme = Theme.of(context);
    Color _background(BuildContext context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return isDark ? const Color(0xFF1A1D23) : const Color(0xFFFFFFFF);
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _background(context),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: controller.getUsersForListing(listingId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _stateWidget(
              icon: Icons.error_outline,
              text: "Error loading users",
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return _stateWidget(
              icon: Icons.people_outline,
              text: "No conversations yet",
            );
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final chat = users[index].data() as Map<String, dynamic>;
              final currentUserId = controller.currentUser!.uid;

              final isBuyer = chat['buyerId'] == currentUserId;
              final otherUserId = isBuyer ? chat['sellerId'] : chat['buyerId'];

              final lastMessage = chat['lastMessage'] ?? "Start conversation";
              final time = chat['lastMessageTime'];

              return FutureBuilder<Map<String, dynamic>?>(
                future: controller.getUserCached(otherUserId),
                builder: (context, userSnap) {
                  if (!userSnap.hasData) {
                    return _shimmerTile();
                  }

                  final user = userSnap.data!;
                  final userName = user['name'] ?? "User";
                  final userImage = user['image'] ?? "";

                  return InkWell(
                    onTap: () {
                      Get.toNamed(
                        '/chatRoom',
                        arguments: {
                          "chatId": chat['chatId'],
                          "listingTitle": chat['listingTitle'],
                          "listingImage": chat['listingImage'],
                          "userName": userName, // ✅ ADD THIS
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        border: Border(
                          bottom: BorderSide(
                            color: theme.dividerColor.withOpacity(0.2),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          /// 👤 AVATAR
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: theme.brightness == Brightness.dark
                                ? Colors.grey.shade800
                                : theme.primaryColor.withOpacity(0.1),

                            backgroundImage: userImage.isNotEmpty
                                ? NetworkImage(userImage)
                                : null,

                            child: userImage.isEmpty
                                ? Icon(
                                    Icons.person,
                                    color: theme.brightness == Brightness.dark
                                        ? Colors.white
                                        : theme.primaryColor,
                                  )
                                : null,
                          ),

                          const SizedBox(width: 12),

                          /// 💬 CHAT INFO
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// NAME + TIME
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        userName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                    Text(
                                      _formatTime(time),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(color: theme.hintColor),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 6),

                                /// LAST MESSAGE + UNREAD
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        lastMessage,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(color: theme.hintColor),
                                      ),
                                    ),

                                    if ((chat['unreadCount'] ?? 0) > 0)
                                      Container(
                                        margin: const EdgeInsets.only(left: 6),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.primaryColor,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          chat['unreadCount'].toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
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
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  /// ⏱️ WHATSAPP STYLE TIME FORMAT
  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return "";

    final DateTime date = timestamp.toDate();
    final now = DateTime.now();

    if (now.difference(date).inDays == 0) {
      return TimeOfDay.fromDateTime(date).format(Get.context!);
    } else if (now.difference(date).inDays == 1) {
      return "Yesterday";
    } else {
      return "${date.day}/${date.month}/${date.year}";
    }
  }

  /// ⚪ EMPTY / ERROR STATE
  Widget _stateWidget({required IconData icon, required String text}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 50, color: Colors.grey),
          const SizedBox(height: 10),
          Text(text, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  /// ✨ LOADING TILE
  Widget _shimmerTile() {
    return const ListTile(
      leading: CircleAvatar(radius: 24, backgroundColor: Colors.grey),
      title: SizedBox(
        height: 10,
        child: DecoratedBox(decoration: BoxDecoration(color: Colors.grey)),
      ),
      subtitle: SizedBox(
        height: 10,
        child: DecoratedBox(decoration: BoxDecoration(color: Colors.grey)),
      ),
    );
  }
}
