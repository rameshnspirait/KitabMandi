import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/core/constants/app_string.dart';
import 'package:kitab_mandi/core/utils/validators.dart';
import 'package:kitab_mandi/modules/auth/controller/auth_controller.dart';
import 'package:kitab_mandi/widgets/app_button.dart';
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

  void forgotPassword() {}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = theme.textTheme.bodyLarge?.color;
    final secondaryText = theme.textTheme.bodySmall?.color;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      body: Column(
        children: [
          /// 🔥 HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryDark,
                  AppColors.primary,
                  AppColors.secondaryDark,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Column(
              children: [
                Image.asset("assets/splash.png", height: 70),
                const SizedBox(height: 12),
                Text(
                  "KitabMandi",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Buy • Sell • Save • Learn",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          /// 🔽 FORM
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    /// 💎 CARD
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.4)
                                : Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          /// NAME
                          if (!isLogin) ...[
                            AppTextField(
                              controller: nameController,
                              hintText: AppStrings.name,
                              validator: (v) =>
                                  Validators.validateName(v ?? ""),
                            ),
                            const SizedBox(height: 16),
                          ],

                          /// EMAIL
                          AppTextField(
                            controller: emailController,
                            hintText: AppStrings.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => Validators.validateEmail(v ?? ""),
                          ),

                          const SizedBox(height: 16),

                          /// PASSWORD
                          AppTextField(
                            controller: passwordController,
                            hintText: AppStrings.password,
                            obscureText: obscurePassword,
                            validator: (v) =>
                                Validators.validatePassword(v ?? ""),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: theme.iconTheme.color,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                            ),
                          ),

                          /// FORGOT PASSWORD
                          if (isLogin)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: forgotPassword,
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 20),

                          /// BUTTON
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

                    const SizedBox(height: 25),

                    /// DIVIDER
                    Row(
                      children: [
                        Expanded(child: Divider(color: theme.dividerColor)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "OR",
                            style: TextStyle(color: secondaryText),
                          ),
                        ),
                        Expanded(child: Divider(color: theme.dividerColor)),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// GOOGLE BUTTON
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isDark ? theme.cardColor : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: theme.dividerColor),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withOpacity(0.3)
                                  : Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/google.png", height: 22),
                            const SizedBox(width: 12),
                            Text(
                              "Continue with Google",
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    /// TOGGLE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLogin
                              ? "Don't have an account? "
                              : "Already have an account? ",
                          style: TextStyle(color: secondaryText),
                        ),
                        GestureDetector(
                          onTap: toggleMode,
                          child: Text(
                            isLogin ? "Sign Up" : "Login",
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// TERMS
                    Text(
                      "By continuing, you agree to our Terms & Privacy Policy",
                      style: TextStyle(fontSize: 12, color: secondaryText),
                      textAlign: TextAlign.center,
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
