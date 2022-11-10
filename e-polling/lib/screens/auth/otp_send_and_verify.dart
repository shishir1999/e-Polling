import 'package:flutter/material.dart';

import '../../../helpers.dart';
import 'send_otp.dart';
import 'verify_otp.dart';

const kOTPControls = {
  OTPPurpose.recovery: {
    'title': 'Password Recovery',
    'description': 'Enter your email to receive an OTP to reset your password',
    'endpoint': '/auth/otp/send-recovery-email',
    'buttonText': 'Send OTP',
  },
  OTPPurpose.verification: {
    'title': 'Lets verify your email',
    'description':
        'Enter your email to receive an OTP to verify your email address',
    'endpoint': '/auth/otp/send-verification-email',
    'buttonText': 'Send OTP',
  },
  OTPPurpose.voting: {
    'title': 'Confirm its you',
    'description': 'Before you can vote, we need to confirm its really you trying to vote',
    'endpoint': '/auth/otp/send-voting-email',
    'buttonText': 'Send Confirmation Code',
  },
};

class OTPSendAndVerify extends StatefulWidget {
  final OTPPurpose purpose;

  final void Function(String, BuildContext) onOTPVerified;

  const OTPSendAndVerify({required this.onOTPVerified, required this.purpose, Key? key}) : super(key: key);

  @override
  State<OTPSendAndVerify> createState() => _OTPSendAndVerifyState();
}

class _OTPSendAndVerifyState extends State<OTPSendAndVerify> {
  @override
  Widget build(BuildContext context) {
    return SendOTP(
      purpose: widget.purpose,
      onSent: (email, c) {
        Navigator.of(c).push(
          MaterialPageRoute(
            builder: (c) => VerifyOTP(
              email,
              purpose: widget.purpose,
              onVerified: widget.onOTPVerified,
            ),
          ),
        );
      },
    );
  }
}
