import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants/app_colors.dart';
import 'constants/app_text_styles.dart';
import 'screens/home_screen.dart';
import 'screens/ai_profile_screen.dart';
import 'screens/credit_purchase_screen.dart';
import 'providers/ai_characters_provider.dart';
import 'providers/credits_provider.dart';

class AIChatApp extends StatelessWidget {
  const AIChatApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access providers to trigger initial loading
    final charactersProvider =
        Provider.of<AICharactersProvider>(context, listen: false);
    final creditsProvider =
        Provider.of<CreditsProvider>(context, listen: false);

    // Load initial data
    Future.microtask(() {
      charactersProvider.loadCharacters();
      charactersProvider.loadCategories();
      creditsProvider.loadCreditPackages();
    });

    return MaterialApp(
      title: 'AI Chat App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          background: AppColors.background,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        textTheme: const TextTheme(
          displayLarge: AppTextStyles.h1,
          displayMedium: AppTextStyles.h2,
          displaySmall: AppTextStyles.h3,
          headlineMedium: AppTextStyles.h4,
          bodyLarge: AppTextStyles.bodyLarge,
          bodyMedium: AppTextStyles.bodyMedium,
          bodySmall: AppTextStyles.bodySmall,
          labelLarge: AppTextStyles.buttonLarge,
          labelMedium: AppTextStyles.buttonMedium,
        ),
        fontFamily: 'Poppins',
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: AppTextStyles.h3,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            textStyle: AppTextStyles.buttonLarge,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
      localizationsDelegates: const [
        // GlobalMaterialLocalizations.delegate,
        // GlobalWidgetsLocalizations.delegate,
        // GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        // Add more locales as needed
      ],
      initialRoute: '/rofile',
      routes: {
        '/': (context) => const HomeScreen(),
        '/profile': (context) => const AIProfileScreen(),
        // '/chat': (context) => const ChatScreen(),
        '/purchase': (context) => const CreditPurchaseScreen(),
        // '/onboarding': (context) => const OnboardingScreen(),
      },
    );
  }
}
