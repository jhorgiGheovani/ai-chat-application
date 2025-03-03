import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

import 'app.dart';
import 'providers/ai_characters_provider.dart';
import 'providers/credits_provider.dart';
import 'constants/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize RevenueCat
  await Purchases.setLogLevel(LogLevel.debug);
  await Purchases.configure(
      PurchasesConfiguration('your-revenuecat-public-api-key'));

  // Setup Mixpanel
  // final mixpanel = await Mixpanel.init(
  //   'your-mixpanel-token',
  //   optOutTrackingDefault: false,
  // );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        // Provider<Mixpanel>.value(value: mixpanel),
        ChangeNotifierProvider(create: (_) => AICharactersProvider()),
        ChangeNotifierProvider(create: (_) => CreditsProvider()),
      ],
      child: const AIChatApp(),
    ),
  );
}
