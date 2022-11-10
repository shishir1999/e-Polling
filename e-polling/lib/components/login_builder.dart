import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/user_controller.dart';
import '../models/user.dart';

class LoginBuilder extends StatelessWidget {
  final Function(BuildContext, User?) builder;
  const LoginBuilder({required this.builder, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Consumer<UserController>(builder: (context, userController, child) {
      return builder(context, userController.session);
    });
  }
}
