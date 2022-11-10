import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jsend/jsend.dart';
import '../../../constants.dart';
import '../../../helpers.dart';
import '../../../components/default_text_field.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  final String optId;
  const RegisterPage(this.optId, {Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool toggleCheckbox = false;
  bool _passwordVisible = false;
  bool _passwordConfirmVisible = false;
  bool _isSendingRequest = false;

  final _formKey = GlobalKey<FormState>();

  jsendResponse? lastResponse;

  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _userPasswordController = TextEditingController();
  final _userPasswordConfirmController = TextEditingController();

  void toggleCheckBox() {
    setState(() {
      toggleCheckbox = !toggleCheckbox;
    });
  }

  @override
  Widget build(BuildContext context) {
    // _goToCreateAccountPage() async {
    //   Navigator.pushReplacement(context,
    //       MaterialPageRoute(builder: (context) => const CreateAccountPage()));
    // }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 40, 0, 0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 30),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 0, 20),
              child: Container(
                alignment: Alignment.topLeft,
                child: Text("Enter your details",
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
                      "Fullname",
                      style: GoogleFonts.manrope(
                          textStyle: body01,
                          color: grey2,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: DefaultTextField("Enter your full name",
                        controller: _nameController,
                        validator: (v) =>
                            customValidator(v, lastResponse, 'name', true)),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 0, 10),
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Phone Number",
                      style: GoogleFonts.manrope(
                          textStyle: body01,
                          color: grey2,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: DefaultTextField("Enter your phone number",
                        controller: _phoneNumberController,
                        validator: (v) =>
                            customValidator(v, lastResponse, 'phone', true)),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 0, 10),
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Password",
                      style: GoogleFonts.manrope(
                          textStyle: body01,
                          color: grey2,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      controller: _userPasswordController,
                      obscureText: !_passwordVisible,
                      validator: (v) =>
                          customValidator(v, lastResponse, 'password', true),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: grey3),
                        ),
                        contentPadding: const EdgeInsets.fromLTRB(10, 14, 0, 0),
                        fillColor: Colors.white,
                        hintText: "Enter your password",
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
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 0, 10),
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Confirm Password",
                      style: GoogleFonts.manrope(
                          textStyle: body01,
                          color: grey2,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      controller: _userPasswordConfirmController,
                      obscureText: !_passwordConfirmVisible,
                      validator: (String? v) {
                        if (v == null || v.isEmpty) return "Required";
                        if (v != _userPasswordController.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: grey3),
                        ),
                        contentPadding: const EdgeInsets.fromLTRB(10, 14, 0, 0),
                        fillColor: Colors.white,
                        hintText: "Confirm your new password",
                        hintStyle: TextStyle(color: grey3),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordConfirmVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: grey1,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordConfirmVisible =
                                  !_passwordConfirmVisible;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  GestureDetector(
                    onTap: !_isSendingRequest
                        ? () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _isSendingRequest = true;
                              });

                              var resp =
                                  await jsendResponse.fromAPIRequest(APIRequest(
                                path: '/auth/register',
                                method: 'POST',
                                payload: {
                                  'name': _nameController.text,
                                  'otp': widget.optId,
                                  'phone': _phoneNumberController.text,
                                  'password': _userPasswordController.text,
                                },
                              ));
                              setState(() {
                                _isSendingRequest = false;
                              });
                              if (resp.status == 'success') {
                                showSnackBar(
                                    "Registered New User Successfully");
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (c) => const LoginPage()),
                                    (route) => false);
                              } else if (resp.status == 'fail') {
                                lastResponse = resp;
                                _formKey.currentState!.validate();
                                lastResponse = null;
                                if (resp.message != null) {
                                  showSnackBar(resp.message!);
                                } else {
                                  showSnackBar("Check your inputs");
                                }
                              } else {
                                showSnackBar(resp.message ?? "Error");
                              }

                              print("valid");
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
                            child: !_isSendingRequest
                                ? Text("Create Account",
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
                    height: 30,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
