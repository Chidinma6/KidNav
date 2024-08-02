import 'dart:convert';
import 'package:http/http.dart' as http;

class TwilioService {
  final String accountSid = 'Enter your accountsid';
  final String authToken = 'Enter token';
  final String twilioNumber = 'enter twilio number';

  Future<void> sendSms(String to, String message) async {
    final String url =
        'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization':
            'Basic ' + base64Encode(utf8.encode('$accountSid:$authToken')),
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'From': twilioNumber,
        'To': to,
        'Body': message,
      },
    );

    if (response.statusCode == 201) {
      print('SMS sent successfully!');
    } else {
      print('Failed to send SMS: ${response.body}');
    }
  }
}
