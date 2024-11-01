import 'package:flutter/material.dart';
import 'package:inq_app/models/Quick_Links_model.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ExternalLinksList extends StatelessWidget {
  const ExternalLinksList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Important Links'),
      ),
      body: ListView.builder(
        itemCount: links.length,
        itemBuilder: (context, index) {
          return LinkItem(
            link: links[index],
            backgroundImage: AssetImage(links[index].image),
          );
        },
      ),
    );
  }
}

class LinkItem extends StatelessWidget {
  final Link link;
  final ImageProvider backgroundImage;

  LinkItem({required this.link, required this.backgroundImage});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () async {
          // replace with your external link
          if (await canLaunchUrlString(link.url)) {
            await launchUrlString(link.url);
          } else {
            throw 'Could not launch ${link.url}';
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: backgroundImage,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(link.title),
            ],
          ),
        ),
      ),
    );
  }
}
