import 'dart:convert';
import 'package:http/http.dart' as http;

class TwilioService {
  final String accountSid = 'ACa772d6efcd34b677ad53aa1f3cfa6e26';
  final String authToken = 'b503d6b8192785553e50b4fe75298b1b';
  final String twilioNumber = '+12602362397';

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
