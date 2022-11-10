import 'package:e_polling/screens/homepage.dart';
import 'package:e_polling/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jsend/jsend.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../controllers/user_controller.dart';
import '../../../helpers.dart';
import '../../../models/user.dart';
import 'register_page.dart';
import 'change_password.dart';
import '../../../components/default_text_field.dart';
import 'otp_send_and_verify.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _passwordVisible = false;
  final _userPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isSendingRequest = false;

  jsendResponse? lastResponse;

  @override
  Widget build(BuildContext context) {
    goToCreateAccountPage() async {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OTPSendAndVerify(
              onOTPVerified: (otpId, ctx) async {
                await Navigator.of(ctx).push(
                    MaterialPageRoute(builder: (ctx) => RegisterPage(otpId)));
                Navigator.of(ctx).pop();
              },
              purpose: OTPPurpose.verification),
        ),
      );
    }

    return Scaffold(
      backgroundColor: white,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 100, 0, 0),
                child: Container(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Login to your account",
                    style: GoogleFonts.manrope(textStyle: headline02),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(20, 0, 0, 10),
                        alignment: Alignment.topLeft,
                        child: const Text(
                          "Email",
                          style: labelStyle,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: DefaultTextField(
                          "Email address ",
                          controller: _emailController,
                          validator: (v) =>
                              customValidator(v, lastResponse, 'email', true),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(20, 15, 0, 10),
                        alignment: Alignment.topLeft,
                        child: const Text(
                          "Password",
                          style: labelStyle,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          validator: (v) => customValidator(
                              v, lastResponse, 'password', true),
                          controller: _userPasswordController,
                          obscureText: !_passwordVisible,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: grey3),
                            ),
                            contentPadding:
                                const EdgeInsets.fromLTRB(10, 14, 0, 0),
                            fillColor: Colors.white,
                            hintText: "Password",
                            hintStyle: TextStyle(color: grey3),
                            suffixIcon: IconButton(
                              icon: Icon(
                                // Based on passwordVisible state choose the icon
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: grey1,
                              ),
                              onPressed: () {
                                // Update the state i.e. toogle the state of passwordVisible variable
                                setState(
                                  () {
                                    _passwordVisible = !_passwordVisible;
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => OTPSendAndVerify(
                                  onOTPVerified: (otpId, ctx) async {
                                    await Navigator.of(ctx).push(
                                      MaterialPageRoute(
                                        builder: (ctx) => ChangePassword(otpId),
                                      ),
                                    );
                                    Navigator.of(ctx).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginPage(),
                                        ),
                                        (route) => false);
                                  },
                                  purpose: OTPPurpose.recovery),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(20, 0, 30, 10),
                          alignment: Alignment.topRight,
                          child: const Text(
                            "Forgot password?",
                            style: labelStyle,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: !_isSendingRequest
                            ? () async {
                                if (_formKey.currentState!.validate()) {
                                  print("valid");
                                  setState(() {
                                    _isSendingRequest = true;
                                  });
                                  try {
                                    var jresp =
                                        await jsendResponse.fromAPIRequest(
                                      APIRequest(
                                        path: '/auth/login',
                                        method: "POST",
                                        payload: {
                                          'email': _emailController.text,
                                          'password':
                                              _userPasswordController.text,
                                        },
                                      ),
                                    );

                                    if (jresp.status == 'success') {
                                      var user = User.fromPayload(
                                          jresp.data['user'],
                                          jresp.data['tokens']['access']
                                              ['token']);
                                      Provider.of<UserController>(context,
                                              listen: false)
                                          .session = user;
                                      Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                            builder: (c) => const HomePage(),
                                          ),
                                          (route) => false);
                                    } else if (jresp.status == 'fail') {
                                      lastResponse = jresp;
                                      _formKey.currentState!.validate();
                                      lastResponse = null;
                                      showSnackBar("Could not login");
                                    } else {
                                      showSnackBar(jresp.message ?? "Error");
                                    }
                                  } catch (e) {
                                    print("Error: $e");
                                  } finally {
                                    setState(
                                      () {
                                        _isSendingRequest = false;
                                      },
                                    );
                                  }
                                } else {
                                  print("Invalid");
                                }
                              }
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                              child: Center(
                                child: !_isSendingRequest
                                    ? Text(
                                        "Login",
                                        style: GoogleFonts.manrope(
                                            textStyle: body01,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      )
                                    : const CupertinoActivityIndicator(
                                        color: primaryBGColor,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 40, 0, 80),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: GoogleFonts.manrope(
                        textStyle: body01,
                        color: grey2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        goToCreateAccountPage();
                      },
                      child: Text(
                        "Create Account",
                        style: GoogleFonts.manrope(
                          textStyle: body01,
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
