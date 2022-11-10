import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jsend/jsend.dart';
import '../../../constants.dart';
import '../../../helpers.dart';
import 'login_page.dart';

class ChangePassword extends StatefulWidget {
  final String otpId;
  const ChangePassword(this.otpId, {Key? key}) : super(key: key);

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  bool toggleCheckbox = false;
  bool _passwordVisible = false;
  final bool _passwordConfirmVisible = false;
  final _formKey = GlobalKey<FormState>();
  bool isSendingRequest = false;
  jsendResponse? lastResponse;

  final _userPasswordController = TextEditingController();
  final _userPasswordConfirmController = TextEditingController();

  void toggleCheckBox() {
    setState(() {
      toggleCheckbox = !toggleCheckbox;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 100, 0, 40),
              child: Container(
                alignment: Alignment.topLeft,
                child: Text("Enter Your New Password",
                    style: GoogleFonts.manrope(
                      textStyle: headline02,
                    )),
              ),
            ),
            Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 0, 0, 10),
                      alignment: Alignment.topLeft,
                      child: Text(
                        "New password",
                        style: GoogleFonts.manrope(
                            textStyle: body02,
                            color: grey2,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
                      child: TextFormField(
                        controller: _userPasswordController,
                        validator: (v) =>
                            customValidator(v, lastResponse, 'password', true),
                        obscureText: !_passwordVisible,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: grey3),
                          ),
                          contentPadding:
                              const EdgeInsets.fromLTRB(10, 14, 0, 0),
                          hintText: "Enter your new password",
                          hintStyle: GoogleFonts.manrope(
                              textStyle: body02, color: grey2),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: grey1,
                            ),
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 10, 0, 10),
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Re-enter new Password",
                        style: GoogleFonts.manrope(
                            textStyle: body02,
                            color: grey2,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                      child: TextFormField(
                        controller: _userPasswordConfirmController,
                        validator: (v) {
                          if (v != _userPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          if (v == null || v.isEmpty) {
                            return 'required';
                          } else {
                            if (v.length < 8) {
                              return "At least 8 characters needed.";
                            }
                          }

                          return null;
                        },
                        obscureText: !_passwordConfirmVisible,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: grey3),
                          ),
                          contentPadding:
                              const EdgeInsets.fromLTRB(10, 14, 0, 0),
                          hintText: "Confirm your new password",
                          hintStyle: GoogleFonts.manrope(
                              textStyle: body02, color: grey2),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: grey1,
                            ),
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    GestureDetector(
                      onTap: !isSendingRequest
                          ? () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  isSendingRequest = true;
                                });
                                var jresp = await jsendResponse
                                    .fromAPIRequest(APIRequest(
                                  path: '/auth/otp/reset-password',
                                  method: 'POST',
                                  payload: {
                                    'otpId': widget.otpId,
                                    'password': _userPasswordController.text,
                                  },
                                ));

                                setState(() {
                                  isSendingRequest = false;
                                });
                                if (jresp.status == 'success') {
                                  showSnackBar(
                                      "Password Changed. Please login.");
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginPage()),
                                      (route) => false);
                                } else if (jresp.status == 'fail') {
                                  lastResponse = jresp;
                                  _formKey.currentState!.validate();
                                  lastResponse = null;
                                  showSnackBar(
                                      (jresp.message ?? "Errored out"));
                                } else {
                                  showSnackBar("Something went wrong. " +
                                      (jresp.message ?? ""));
                                }
                              } else {
                                print("Invalid data");
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
                              child: !isSendingRequest
                                  ? Text("Change Password",
                                      style: GoogleFonts.manrope(
                                          textStyle: body01,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white))
                                  : const CupertinoActivityIndicator(
                                      color: primaryBGColor,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 140,
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
