import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/app_configs_controller.dart';
import '../controllers/user_controller.dart';
import 'auth/login_page.dart';
import 'homepage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultSplashScreen();
  }
}

class DefaultSplashScreen extends StatelessWidget {
  const DefaultSplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: Text(
            "ePolling",
            style: TextStyle(
              fontSize: 24,
            ),
          )),
          Consumer2<UserController, AppConfigController>(
              builder: (context, userController, appConfigController, child) {
            if (!userController.isLoading && !appConfigController.isLoading) {
              Future.microtask(() {
                var route =
                    MaterialPageRoute(builder: (context) => const HomePage());

                if (!userController.sessionExists) {
                  route = MaterialPageRoute(
                      builder: (context) => const LoginPage());
                }

                // route override

                Future.delayed(const Duration(seconds: 4), () {
                  Navigator.of(context)
                      .pushAndRemoveUntil(route, (route) => false);
                });
              });
            }
            return CircularProgressIndicator.adaptive();
          }),
        ],
      ),
    );
  }
}
