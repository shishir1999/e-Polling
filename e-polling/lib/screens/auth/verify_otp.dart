import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jsend/jsend.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';

import '../../../constants.dart';
import '../../../helpers.dart';
import 'otp_send_and_verify.dart';

class VerifyOTP extends StatefulWidget {
  final String emailToVerify;
  final OTPPurpose purpose;
  final void Function(String, BuildContext) onVerified;
  const VerifyOTP(this.emailToVerify,
      {required this.onVerified, required this.purpose, Key? key})
      : super(key: key);

  final maxMinutes = 4;
  final maxSeconds = 59;

  @override
  _VerifyOTPState createState() => _VerifyOTPState();
}

class _VerifyOTPState extends State<VerifyOTP> {
  bool isConfirmingEmail = false;
  bool isResendingEmail = false;
  final OtpFieldController _otpFieldController = OtpFieldController();
  String code = "";
  late int min = widget.maxMinutes;
  Timer? timer;
  late int second = widget.maxSeconds;
  void startTimer() {
    const onSec = Duration(seconds: 1);
    timer = Timer.periodic(onSec, (timer) {
      if (min == 0 && second == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          if (second == 0) {
            min--;
            second = 59;
          } else {
            second--;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (timer != null) timer!.cancel();
  }

  @override
  void initState() {
    setState(() {
      min = widget.maxMinutes;
      second = widget.maxSeconds;
    });
    startTimer();
    super.initState();
  }

  bool goodToConfirm = false;

  bool get goodToResend => min == 0 && second == 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
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
            padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
            child: Container(
              alignment: Alignment.topLeft,
              child: Text(
                  "Please enter the OTP you recieved on ${widget.emailToVerify}",
                  style: GoogleFonts.manrope(
                    textStyle: title302,
                  )),
            ),
          ),
          Form(
              child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: OTPTextField(
                  keyboardType: TextInputType.number,
                  controller: _otpFieldController,
                  otpFieldStyle: OtpFieldStyle(
                    borderColor: grey1,
                  ),
                  spaceBetween: 10,
                  length: 5,
                  width: MediaQuery.of(context).size.width,
                  fieldWidth: 55,
                  style: const TextStyle(fontSize: 17),
                  textFieldAlignment: MainAxisAlignment.spaceAround,
                  fieldStyle: FieldStyle.box,
                  onChanged: (String val) {
                    code = val;
                    if (val.length != 5) {
                      setState(() {
                        goodToConfirm = false;
                      });
                    }
                  },
                  onCompleted: (pin) {
                    setState(() {
                      goodToConfirm = true;
                    });
                    print("Completed: " + pin);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 25, 15, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Expires in ',
                        style: GoogleFonts.manrope(
                            textStyle: body02, color: grey1)),
                    Text("$min: $second",
                        style: GoogleFonts.openSans(
                            textStyle: body02, color: primaryColor)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: isConfirmingEmail
                    ? null
                    : () async {
                        try {
                          if (code.length != 5) throw Exception("Invalid OTP");
                          setState(() {
                            isConfirmingEmail = true;
                          });
                          var jresp = await jsendResponse.fromAPIRequest(
                            APIRequest(
                              path: "/auth/otp/submit",
                              method: "POST",
                              payload: {
                                'code': code,
                                'receiverAddress': widget.emailToVerify
                              },
                            ),
                          );
                          setState(() {
                            isConfirmingEmail = false;
                          });
                          if (jresp.status == "success") {
                            widget.onVerified(jresp.data['otpId'], context);
                          } else {
                            throw Exception(jresp.message);
                          }
                        } catch (e) {
                          showSnackBar(e.toString());
                        }
                      },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: goodToConfirm
                          ? primaryColor
                          : primaryColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                      child: Center(
                        child: !isConfirmingEmail
                            ? Text("Confirm OTP",
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
              GestureDetector(
                onTap: (min == 0 && second == 0)
                    ? () async {
                        setState(() {
                          isResendingEmail = true;
                        });
                        var jresp = await jsendResponse.fromAPIRequest(
                          APIRequest(
                            path: kOTPControls[widget.purpose]!['endpoint'],
                            method: 'POST',
                            payload: {
                              "email": widget.emailToVerify,
                            },
                          ),
                        );
                        if (jresp.status == "success") {
                          showSnackBar("Email Resent");
                          setState(() {
                            min = widget.maxMinutes;
                            second = widget.maxSeconds;
                          });
                          startTimer();
                        } else {
                          showSnackBar(jresp.message ?? "Something went wrong");
                        }
                        setState(() {
                          isResendingEmail = false;
                        });
                      }
                    : null,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                  child: !isResendingEmail
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.replay_outlined),
                            Text(
                              "  Resend again",
                              style: GoogleFonts.manrope(
                                  textStyle: body02,
                                  fontWeight: FontWeight.bold,
                                  color: goodToResend ? primaryColor : grey1),
                            ),
                          ],
                        )
                      : const CupertinoActivityIndicator(
                          color: primaryBGColor,
                        ),
                ),
              )
            ],
          )),
        ],
      ),
    );
  }
}
