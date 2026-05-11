import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/features/seller/controller/seller_controller.dart';
import 'package:kitab_mandi/widgets/app_button.dart';
import 'package:kitab_mandi/widgets/app_text.dart';
import 'package:kitab_mandi/widgets/app_text_field.dart';

class SellerListingView extends StatelessWidget {
  SellerListingView({super.key});

  final controller = Get.put(SellerController());

  Color _background(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1A1D23) : const Color(0xFFFFFFFF);
  }

  Color _card(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF1A1D23)
      : Colors.white;

  Color _border(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? Colors.white.withOpacity(0.05)
      : const Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sell Your Book / Notes"),
        backgroundColor: _background(context),
      ),
      body: Obx(
        () => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= IMAGE =================
              AppText("Upload Photos", style: theme.textTheme.titleMedium),
              const SizedBox(height: 10),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ...List.generate(controller.images.length, (index) {
                    return Stack(
                      children: [
                        Container(
                          height: 90,
                          width: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: FileImage(File(controller.images[index])),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: GestureDetector(
                            onTap: () => controller.removeImage(index),
                            child: const CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.red,
                              child: Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),

                  GestureDetector(
                    onTap: controller.pickImage,
                    child: Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        color: _card(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _border(context)),
                      ),
                      child: const Icon(Icons.add_a_photo_outlined),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // ================= CATEGORY =================
              AppText("Category", style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                children: controller.categories.map((cat) {
                  return ChoiceChip(
                    label: Text(cat),
                    selected: controller.selectedCategory.value == cat,
                    onSelected: (_) => controller.selectedCategory.value = cat,
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // ================= EDUCATION TYPE =================
              AppText("Education Type", style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                children: controller.educationTypes.map((type) {
                  return ChoiceChip(
                    label: Text(type),
                    selected: controller.selectedEducationType.value == type,
                    onSelected: (_) {
                      controller.selectedEducationType.value = type;

                      // reset dependent fields
                      controller.selectedClass.value = "";
                      controller.selectedDegree.value = "";
                      controller.selectedYear.value = "";
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // ================= SCHOOL =================
              if (controller.selectedEducationType.value == "School")
                AppTextField(
                  controller: TextEditingController(
                    text: controller.selectedClass.value,
                  ),
                  hintText: "Select Class",
                  readOnly: true,
                  suffixIcon: PopupMenuButton<String>(
                    icon: const Icon(Icons.arrow_drop_down),
                    onSelected: (val) => controller.selectedClass.value = val,
                    itemBuilder: (_) => controller.schoolClasses
                        .map((e) => PopupMenuItem(value: e, child: Text(e)))
                        .toList(),
                  ),
                ),

              // ================= COLLEGE DEGREE =================
              if (controller.selectedEducationType.value == "College")
                AppTextField(
                  controller: TextEditingController(
                    text: controller.selectedDegree.value,
                  ),
                  hintText: "Select Degree",
                  readOnly: true,
                  suffixIcon: PopupMenuButton<String>(
                    icon: const Icon(Icons.arrow_drop_down),
                    onSelected: (val) {
                      controller.selectedDegree.value = val;
                      controller.selectedYear.value = "";
                    },
                    itemBuilder: (_) => controller.degrees
                        .map((e) => PopupMenuItem(value: e, child: Text(e)))
                        .toList(),
                  ),
                ),

              // ================= COLLEGE YEAR =================
              if (controller.selectedEducationType.value == "College" &&
                  controller.selectedDegree.value.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: AppTextField(
                    controller: TextEditingController(
                      text: controller.selectedYear.value,
                    ),
                    hintText: "Select Year",
                    readOnly: true,
                    suffixIcon: PopupMenuButton<String>(
                      icon: const Icon(Icons.arrow_drop_down),
                      onSelected: (val) => controller.selectedYear.value = val,
                      itemBuilder: (_) => controller
                          .degreeYears[controller.selectedDegree.value]!
                          .map((e) => PopupMenuItem(value: e, child: Text(e)))
                          .toList(),
                    ),
                  ),
                ),

              // ================= EXAM =================
              if (controller.selectedEducationType.value == "Competitive Exam")
                AppTextField(
                  controller: TextEditingController(
                    text: controller.selectedClass.value,
                  ),
                  hintText: "Select Exam",
                  readOnly: true,
                  suffixIcon: PopupMenuButton<String>(
                    icon: const Icon(Icons.arrow_drop_down),
                    onSelected: (val) => controller.selectedClass.value = val,
                    itemBuilder: (_) => controller.exams
                        .map((e) => PopupMenuItem(value: e, child: Text(e)))
                        .toList(),
                  ),
                ),

              const SizedBox(height: 20),

              // ================= CONDITION =================
              AppText("Condition", style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                children: controller.conditions.map((c) {
                  return ChoiceChip(
                    label: Text(c),
                    selected: controller.selectedCondition.value == c,
                    onSelected: (_) => controller.selectedCondition.value = c,
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // ================= TITLE =================
              AppTextField(
                controller: controller.titleController,
                hintText: "Title",
              ),

              const SizedBox(height: 12),

              // ================= PRICE =================
              AppTextField(
                controller: controller.priceController,
                hintText: "Price (₹)",
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 12),

              // ================= LOCATION =================
              AppTextField(
                controller: TextEditingController(text: controller.fullAddress),
                readOnly: true,
                hintText: "Detect Location",
                suffixIcon: controller.isDetectingLocation.value
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.my_location),
                        onPressed: controller.detectLocation,
                      ),
              ),

              const SizedBox(height: 12),

              // ================= DESCRIPTION =================
              AppTextField(
                controller: controller.descriptionController,
                hintText: "Description",
                maxLines: 4,
              ),

              const SizedBox(height: 30),

              // ================= SUBMIT =================
              AppButton(
                text: "Publish Listing",
                isLoading: controller.isUploading.value,
                onPressed: controller.uploadListing,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
