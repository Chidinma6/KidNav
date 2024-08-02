import 'package:flutter/material.dart';
import 'twilio_service.dart';

class CheckSms extends StatefulWidget {
  @override
  _CheckSmsState createState() => _CheckSmsState();
}

class _CheckSmsState extends State<CheckSms> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TwilioService _twilioService = TwilioService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send SMS'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Enter phone number'),
            ),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(labelText: 'Enter message'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _twilioService.sendSms(
                    _phoneController.text, _messageController.text);
              },
              child: Text('Send SMS'),
            ),
          ],
        ),
      ),
    );
  }
}
