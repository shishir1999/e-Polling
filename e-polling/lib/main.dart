import 'package:e_polling/constants.dart';
import 'package:e_polling/screens/splash_screen.dart';
import 'package:e_polling/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:jsend/jsend.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../controllers/app_configs_controller.dart';
import '../controllers/user_controller.dart';
import '../helpers.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  AppManager.navigatorKey = GlobalKey<NavigatorState>();

  if (isInDevelopment) {
    // APIRequest.base = 'http://localhost:3000/';
    // APIRequest.base = 'http://192.168.16.105:3000/';
    APIRequest.base = 'http://10.0.2.2:3000/';
  }
  runApp(MyApp(AppManager.navigatorKey));
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navKey;

  const MyApp(this.navKey, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserController()),
        ChangeNotifierProvider(create: (_) => AppConfigController()),
      ],
      child: MaterialApp(
        theme: EPollingTheme.light(),
        navigatorKey: navKey,
        debugShowCheckedModeBanner: false,
        title: "ePolling",
        routes: {
          '/': (context) => const SplashScreen(),
        },
        initialRoute: "/",
      ),
    );
  }
}
