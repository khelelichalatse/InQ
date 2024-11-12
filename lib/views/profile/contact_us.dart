import 'package:flutter/material.dart';
import 'package:inq_app/functional_supports/responsive.dart';
import 'package:lottie/lottie.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({Key? key}) : super(key: key);

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Lottie.asset(
                  'assets/ContactUs.json',
                  height: SizeConfig.height(30),
                  fit: BoxFit.contain,
                  controller: _animationController,
                  repeat: false,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  'Get in touch with us!',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.tertiary),
                ),
              ),
              const SizedBox(height: 20),
              _buildInfoCard(
                context: context,
                icon: Icons.access_time,
                title: 'Hours',
                content: 'Monday to Friday – 08:00 to 16:30',
              ),
              const SizedBox(height: 20),
              _buildCampusCard(
                context: context,
                campusName: 'Bloemfontein Campus',
                email: 'wellness@cut.ac.za',
                phone: '+27 (0)51 507 3154',
              ),
              const SizedBox(height: 20),
              _buildCampusCard(
                context: context,
                campusName: 'Welkom Campus',
                email: 'wellness@cut.ac.za',
                phone: '+27(0)51 910 3569',
              ),
              const SizedBox(height: 20),
              Card(
                color: Theme.of(context).colorScheme.tertiary,
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: Colors.orange, size: 24),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Feel free to reach out to us for any inquiries or support.',
                          style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onTertiary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      {required BuildContext context,
      required IconData icon,
      required String title,
      required String content}) {
    return Card(
      color: Theme.of(context).colorScheme.onTertiary,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.orange, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.tertiary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.tertiary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampusCard(
      {required BuildContext context,
      required String campusName,
      required String email,
      required String phone}) {
    return Card(
      color: Theme.of(context).colorScheme.onTertiary,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              campusName,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange),
            ),
            const SizedBox(height: 16),
            _buildContactInfo(context, Icons.email, email),
            const SizedBox(height: 8),
            _buildContactInfo(context, Icons.phone, phone),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.tertiary, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
              fontSize: 16, color: Theme.of(context).colorScheme.tertiary),
        ),
      ],
    );
  }
}
