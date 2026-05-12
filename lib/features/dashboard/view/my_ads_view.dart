import 'package:flutter/material.dart';

class MyAdsView extends StatelessWidget {
  const MyAdsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Ads")),
      body: const Center(child: Text("My Ads View")),
    );
  }
}
