import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/features/dashboard/model/listing_model.dart';

class ChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final currentUser = FirebaseAuth.instance.currentUser;
  Map<String, Map<String, dynamic>> userCache = {};

  /// 🔥 START CHAT
  Future<void> startChat(ListingModel listing) async {
    final buyerId = currentUser!.uid;
    final sellerId = listing.seller['uid'];

    final chatId = "${listing.id}_$buyerId";

    final chatRef = _firestore.collection('chats').doc(chatId);

    final chatDoc = await chatRef.get();

    if (!chatDoc.exists) {
      await chatRef.set({
        "chatId": chatId,
        "listingId": listing.id,
        "listingTitle": listing.title,
        "price": listing.price,
        "listingImage": listing.images.isNotEmpty ? listing.images.first : "",
        "buyerId": buyerId,
        "sellerId": sellerId,
        "participants": [buyerId, sellerId],
        "lastMessage": "Hi",
        "lastMessageTime": FieldValue.serverTimestamp(),
      });

      await chatRef.collection('messages').add({
        "senderId": buyerId,
        "message": "Hi",
        "timestamp": FieldValue.serverTimestamp(),
      });
    }

    /// 👉 OPEN CHAT DIRECTLY
    Get.toNamed(
      '/chatRoom',
      arguments: {
        "chatId": chatId,
        "listingTitle": listing.title,
        "listingImage": listing.images.first,
        "userName": listing.seller['name'],
      },
    );
  }

  Future<Map<String, dynamic>?> getUserById(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) return doc.data();
    } catch (e) {
      debugPrint("User fetch error: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserCached(String uid) async {
    if (userCache.containsKey(uid)) {
      return userCache[uid];
    }

    final user = await getUserById(uid);

    if (user != null) {
      userCache[uid] = user;
    }

    return user;
  }

  /// 🛒 BUYING → PRODUCTS
  Stream<QuerySnapshot> getBuyingProducts() {
    return _firestore
        .collection('chats')
        .where('buyerId', isEqualTo: currentUser!.uid)
        .snapshots();
  }

  /// 📦 SELLING → PRODUCTS
  Stream<QuerySnapshot> getSellingProducts() {
    return _firestore
        .collection('chats')
        .where('sellerId', isEqualTo: currentUser!.uid)
        .snapshots();
  }

  /// 👥 USERS FOR PRODUCT
  Stream<QuerySnapshot> getUsersForListing(String listingId) {
    return _firestore
        .collection('chats')
        .where('listingId', isEqualTo: listingId)
        .snapshots();
  }
}
