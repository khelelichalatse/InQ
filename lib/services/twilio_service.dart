import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:twilio_flutter/twilio_flutter.dart';

class TwilioServiceOTP {
  final String _accountSid = 'AC060c09c7e9e0031a06ddb15dba6c13fd';
  final String _authToken = '10437426417f635347e667809ce10f8f';
  final String _serviceSid = 'VA96f88bce543ae8dae96a91513557ed16';

  Future<bool> sendVerificationCode(String phoneNumber) async {
    try {
      print('Sending verification code to: $phoneNumber');
      
      final url = Uri.parse('https://verify.twilio.com/v2/Services/$_serviceSid/Verifications');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Basic ' + base64Encode(utf8.encode('$_accountSid:$_authToken')),
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'To': phoneNumber,
          'Channel': 'sms',
        },
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error sending verification code: $e');
      return false;
    }
  }

  Future<bool> verifyCode(String phoneNumber, String code) async {
    try {
      print('Verifying code: $code for phone: $phoneNumber');
      
      final url = Uri.parse('https://verify.twilio.com/v2/Services/$_serviceSid/VerificationCheck');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Basic ' + base64Encode(utf8.encode('$_accountSid:$_authToken')),
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'To': phoneNumber,
          'Code': code,
        },
      ); 

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        return responseBody['status'] == 'approved';
      }
      return false;
    } catch (e) {
      print('Error verifying code: $e');
      return false;
    }
  }
}
class TwilioServiceSMS {
  late TwilioFlutter twilioFlutter;

  TwilioServiceSMS() {
    twilioFlutter = TwilioFlutter(
      accountSid: 'AC060c09c7e9e0031a06ddb15dba6c13fd',
      authToken: '10437426417f635347e667809ce10f8f',
      twilioNumber: '+1 850 741 7735',
    );
  }

  Future<void> sendSMS(String toNumber, String messageBody) async {
    try {
      await twilioFlutter.sendSMS(
        toNumber: toNumber,
        messageBody: messageBody,
      );
      print('SMS sent successfully');
    } catch (e) {
      print('Error sending SMS: $e');
    }
  }
}