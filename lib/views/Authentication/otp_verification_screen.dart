import 'dart:async';
import 'package:flutter/material.dart';
import 'package:inq_app/services/twilio_service.dart';
import 'package:inq_app/widgets/my_buttons.dart';
import 'package:inq_app/widgets/my_otp_row.dart';
import 'package:inq_app/functional_supports/responsive.dart';
import 'package:lottie/lottie.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final VoidCallback onVerificationSuccess;

  const OtpVerificationScreen({
    Key? key,
    required this.phoneNumber,
    required this.onVerificationSuccess,
  }) : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _twilioService = TwilioServiceOTP();
  int resendTime = 60;
  late Timer countdownTimer;
  final _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    countdownTimer.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void startTimer() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (resendTime > 0) {
          resendTime--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> verifyOtp() async {
    if (_otpController.text.length == 6) {
      bool verified = await _twilioService.verifyCode(
        widget.phoneNumber,
        _otpController.text,
      );
      if (verified) {
        widget.onVerificationSuccess();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid verification code')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid 6-digit code')),
      );
    }
  }

  Future<void> resendOtp() async {
    bool sent = await _twilioService.sendVerificationCode(widget.phoneNumber);
    if (sent) {
      setState(() {
        resendTime = 60;
      });
      startTimer();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to resend verification code')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Verification',
          style: TextStyle(
            fontSize: SizeConfig.text(5.5),
          ),
        ),
      ),
      body: SafeArea(
        child: ResponsiveWidget(
          mobile: _buildMobileLayout(),
          tablet: _buildTabletLayout(),
          desktop: _buildDesktopLayout(),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.width(5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: SizeConfig.width(15)),
              child: Center(
                child: Lottie.asset(
                  'assets/verifyOTP.json',
                  height: SizeConfig.height(30),
                  fit: BoxFit.contain,
                  repeat: false,
                ),
              ),
            ),
            _buildHeader(),
            SizedBox(height: SizeConfig.height(2)),
            MyOtpRow(controller: _otpController),
            SizedBox(height: SizeConfig.height(2)),
            _buildResendOtpSection(),
            SizedBox(height: SizeConfig.height(2)),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Center(
      child: SizedBox(
        width: SizeConfig.width(60),
        child: _buildMobileLayout(),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: SizedBox(
        width: SizeConfig.width(40),
        child: _buildMobileLayout(),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: SizeConfig.height(3)),
        Text(
          "We have sent you a verification code to:",
          style: TextStyle(
            fontSize: SizeConfig.text(3.5),
          ),
        ),
        SizedBox(height: SizeConfig.height(3)),
        Text(
          widget.phoneNumber,
          style: TextStyle(
            fontSize: SizeConfig.text(4),
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildResendOtpSection() {
    return Wrap(
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          resendTime != 0
              ? "You can resend OTP in: "
              : "Haven't received an OTP yet? ",
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: SizeConfig.text(4),
          ),
        ),
        if (resendTime != 0)
          Text(
            "$resendTime",
            style: TextStyle(
              fontSize: SizeConfig.text(4),
              color: Theme.of(context).colorScheme.secondary,
            ),
          )
        else
          TextButton(
            onPressed: resendOtp,
            child: Text(
              "Resend",
              style: TextStyle(
                fontSize: SizeConfig.text(4),
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: MyNegativeButton(
            text: "Resend",
            onTap: resendTime == 0 ? resendOtp : null,
          ),
        ),
        SizedBox(width: SizeConfig.width(2)),
        Expanded(
          child: MyPositiveButton(
            text: "Confirm",
            onTap: verifyOtp,
          ),
        ),
      ],
    );
  }
}
