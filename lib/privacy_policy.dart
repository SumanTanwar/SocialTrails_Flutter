import 'package:flutter/material.dart';

class PrivacyPolicy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 1),
            Text(
              'Privacy Policy',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Last updated: 30-09-2024',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 7),
            Text(
              'SocialTrails collects, uses, and protects your information when you use our app.',
            ),
            SizedBox(height: 7),
            Text(
              'Information We Collect',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '- We may collect personal information such as your name, email address, and profile information when you create an account or interact with our app.\n'
                  '- We use cookies and similar technologies to enhance your experience and analyze usage patterns.',
            ),
            SizedBox(height: 7),
            Text(
              'How We Use Your Information',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '- To provide and maintain our app\n'
                  '- To notify you about changes to our app\n'
                  '- To allow you to participate in interactive features\n'
                  '- To provide customer support\n'
                  '- To gather analysis so we can improve our app',
            ),
            SizedBox(height: 7),
            Text(
              'Sharing Your Information',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'We do not sell or rent your personal information to third parties. We may share your information in the following circumstances:',
            ),
            SizedBox(height: 5),
            Text(
              '- With service providers to assist us in operating our app\n'
                  '- To comply with legal obligations\n'
                  '- To protect and defend our rights',
            ),
            SizedBox(height: 7),
            Text(
              'Data Security',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'We take data security seriously and implement reasonable measures to protect your information from unauthorized access, use, or disclosure.',
            ),
            SizedBox(height: 7),
            Text(
              'Changes to the privacy policy',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'We may update our Privacy Policy from time to time.',
            ),
            SizedBox(height: 7),
            Text(
              'Contact Information',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'For questions, contact us at:\n- Email: socialtrails2024@gmail.com',
            ),
            SizedBox(height: 7),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop(); // Navigate back to the previous screen
              },
              child: Text(
                'Back',
                style: TextStyle(
                  color: Colors.purple, // Use your purple color
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
