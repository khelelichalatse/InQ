import 'package:flutter/material.dart';

class FAQpage extends StatefulWidget {
  const FAQpage({super.key});

  @override
  State<FAQpage> createState() => _FAQpageState();
}

class _FAQpageState extends State<FAQpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
      title: const Text('FAQ'),
      backgroundColor: Colors.orange,
    ));
  }
}
