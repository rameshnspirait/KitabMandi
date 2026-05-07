import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:kitab_mandi/core/constants/app_string.dart';
import 'package:kitab_mandi/core/utils/validators.dart';
import 'package:kitab_mandi/modules/auth/controller/auth_controller.dart';
import 'package:kitab_mandi/widgets/app_button.dart';
import 'package:kitab_mandi/widgets/app_text.dart';
import 'package:kitab_mandi/widgets/app_text_field.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  final controller = Get.find<AuthController>();

  final _formKey = GlobalKey<FormState>();

  bool isLogin = true;
  bool obscurePassword = true;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void toggleMode() {
    setState(() {
      isLogin = !isLogin;
      clearFields();
    });
  }

  void clearFields() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    _formKey.currentState?.reset();
  }

  void submit() {
    if (!_formKey.currentState!.validate()) return;

    if (isLogin) {
      controller.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
    } else {
      controller.signUp(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          // 🔥 TOP HEADER (THEME BASED)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 40),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.menu_book,
                  size: 50,
                  color: theme.colorScheme.onPrimary,
                ),
                const SizedBox(height: 10),
                AppText(
                  "KitabMandi",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                AppText(
                  "Buy & Sell Used Books",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          // 🔽 FORM SECTION
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // 🔥 CARD CONTAINER
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: theme.brightness == Brightness.dark
                                ? Colors.black.withOpacity(0.4)
                                : Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // 👤 NAME
                          if (!isLogin) ...[
                            AppTextField(
                              controller: nameController,
                              hintText: AppStrings.name,
                              validator: (v) =>
                                  Validators.validateName(v ?? ""),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // 📧 EMAIL
                          AppTextField(
                            controller: emailController,
                            hintText: AppStrings.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => Validators.validateEmail(v ?? ""),
                          ),

                          const SizedBox(height: 16),

                          // 🔑 PASSWORD
                          AppTextField(
                            controller: passwordController,
                            hintText: AppStrings.password,
                            obscureText: obscurePassword,
                            validator: (v) =>
                                Validators.validatePassword(v ?? ""),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                            ),
                          ),

                          const SizedBox(height: 20),

                          // 🔘 SUBMIT BUTTON
                          Obx(
                            () => AppButton(
                              text: isLogin
                                  ? AppStrings.login
                                  : AppStrings.signup,
                              isLoading: controller.isLoading.value,
                              onPressed: submit,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🔥 DIVIDER
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: AppText("OR"),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 🔥 GOOGLE BUTTON
                    AppButton(
                      text: "Continue with Google",
                      color: theme.cardColor,
                      onPressed: () {
                        // controller.signInWithGoogle();
                      },
                    ),

                    const SizedBox(height: 20),

                    // 🔁 TOGGLE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppText(
                          isLogin
                              ? "Don't have an account? "
                              : "Already have an account? ",
                        ),
                        GestureDetector(
                          onTap: toggleMode,
                          child: AppText(
                            isLogin ? AppStrings.signup : AppStrings.login,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
