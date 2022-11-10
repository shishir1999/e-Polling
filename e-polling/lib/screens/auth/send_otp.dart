import 'package:e_polling/components/default_text_field.dart';
import 'package:e_polling/controllers/user_controller.dart';
import 'package:e_polling/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jsend/jsend.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../helpers.dart';
import 'otp_send_and_verify.dart';

class SendOTP extends StatefulWidget {
  final OTPPurpose purpose;
  final void Function(String, BuildContext) onSent;
  const SendOTP({required this.onSent, required this.purpose, Key? key})
      : super(key: key);

  @override
  _SendOTPState createState() => _SendOTPState();
}

class _SendOTPState extends State<SendOTP> {
  bool _isSendingRequest = false;

  jsendResponse? lastResponse;

  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.purpose == OTPPurpose.voting) {
      if (Provider.of<UserController>(context, listen: false).sessionExists) {
        _emailController.text =
            Provider.of<UserController>(context, listen: false).session!.email;
      }
    } else {
      _emailController.text = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
                child: Container(
                  alignment: Alignment.topLeft,
                  child: Text(
                    kOTPControls[widget.purpose]!['title']!,
                    style: GoogleFonts.manrope(
                      textStyle: headline02,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 0, 35),
                child: Container(
                  alignment: Alignment.topLeft,
                  child: Text(kOTPControls[widget.purpose]!['description']!,
                      style:
                          GoogleFonts.manrope(textStyle: body02, color: grey1)),
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 0, 0, 10),
                      alignment: Alignment.topLeft,
                      child: const Text(
                        "Email Address",
                        style: labelStyle,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: DefaultTextField(
                        "Enter your email",
                        readOnly: widget.purpose == OTPPurpose.voting,
                        controller: _emailController,
                        validator: (v) =>
                            customValidator(v, lastResponse, "email", true),
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
                      child: !_isSendingRequest
                          ? GestureDetector(
                              onTap: () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    _isSendingRequest = true;
                                  });
                                  var jresp =
                                      await jsendResponse.fromAPIRequest(
                                    APIRequest(
                                      path: kOTPControls[widget.purpose]![
                                          'endpoint'],
                                      method: 'POST',
                                      payload: {
                                        "email": _emailController.text,
                                      },
                                    ),
                                  );
                                  if (jresp.status == "success") {
                                    widget.onSent(
                                        _emailController.text, context);
                                  } else if (jresp.status == 'fail') {
                                    lastResponse = jresp;
                                    _formKey.currentState!.validate();
                                    lastResponse = null;
                                  } else {
                                    showSnackBar(jresp.message ??
                                        "Something went wrong");
                                  }
                                  setState(() {
                                    _isSendingRequest = false;
                                  });
                                }
                              },
                              child: Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 0, 0, 0),
                                  child: Center(
                                    child: Text(
                                      kOTPControls[widget.purpose]![
                                          'buttonText']!,
                                      style: GoogleFonts.manrope(
                                          textStyle: body01,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox(
                              height: 44,
                              width: double.infinity,
                              child: CupertinoActivityIndicator(
                                color: kPrimaryColor,
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
