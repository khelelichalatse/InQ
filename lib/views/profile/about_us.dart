import 'package:flutter/material.dart';

// Screen that displays information about the development team and company
class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with orange background matching app theme
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: Colors.orange,
      ),
      // Main content in scrollable list view
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Company logo
          Image.asset('assets/M4NSoftwares.png'),
          const SizedBox(height: 20),
          
          // Company description
          const Text(
            'We are final-year IT students at CUT, passionate about creating innovative software solutions.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 30),
          
          // Team section header
          const Text(
            'Our Team',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Team member cards
          // Each card displays member photo, name and role
          _buildTeamMember(
            name: 'Nick Baloi',
            role: 'Full Stack Web Developer',
            imagePath: 'assets/team/nick.jpg',
            context: context,
          ),
          _buildTeamMember(
            name: 'Moeketsi Chalatse',
            role: 'Software Engineer',
            imagePath: 'assets/team/max.jpg',
            context: context,
          ),
          _buildTeamMember(
            name: 'Chobane Khaketla',
            role: 'Back-end Developer',
            imagePath: 'assets/team/chobane.jpg',
            context: context,
          ),
          _buildTeamMember(
            name: 'Mvelo Mgenge',
            role: 'Mobile App Developer & UI Designer',
            imagePath: 'assets/team/mvelo.jpg',
            context: context,
          ),
          _buildTeamMember(
            name: 'Chalene Visser',
            role: 'Mobile App Developer',
            imagePath: 'assets/team/chalene.jpg',
            context: context,
          ),
        ],
      ),
    );
  }

  // Helper method to build consistent team member cards
  Widget _buildTeamMember({
    required String name,
    required String role,
    required String imagePath,
    required BuildContext context,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Theme.of(context).colorScheme.onTertiary,
      child: ListTile(
        // Circular profile photo with error handling
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.orange.shade200,
          backgroundImage: AssetImage(imagePath),
          onBackgroundImageError: (exception, stackTrace) {
            print('Failed to load image: $imagePath');
            print('Error: $exception');
          },
        ),
        // Member name and role
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(role),
      ),
    );
  }
}
