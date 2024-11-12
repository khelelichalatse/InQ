import 'package:flutter/material.dart';


class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Image.asset('assets/M4NSoftwares.png'),
          const SizedBox(height: 20),
          const Text(
            'We are final-year IT students at CUT, passionate about creating innovative software solutions.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 30),
          const Text(
            'Our Team',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
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
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.orange.shade200,
          backgroundImage: AssetImage(imagePath),
          onBackgroundImageError: (exception, stackTrace) {
            print('Failed to load image: $imagePath');
            print('Error: $exception');
          },
        ),
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
