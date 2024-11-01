import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inq_app/functional_supports/responsive.dart';
import 'package:inq_app/views/emails/create_email.dart';
import 'package:intl/intl.dart';
import 'package:inq_app/views/emails/email_detail_page.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class EmailLayout extends StatefulWidget {
  final Function(bool) onSelectionModeChanged;
  final Set<String> selectedEmails;
  final Function(Set<String>) onSelectedEmailsChanged;
  final Function(Set<String>) onDeleteEmails;

  const EmailLayout({
    Key? key,
    required this.onSelectionModeChanged,
    required this.selectedEmails,
    required this.onSelectedEmailsChanged,
    required this.onDeleteEmails,
  }) : super(key: key);

  void deleteEmails(Set<String> emailIds) {
    // Forward the delete request to the callback
    onDeleteEmails(emailIds);
  }

  @override
  State<EmailLayout> createState() => _EmailLayoutState();
}

class _EmailLayoutState extends State<EmailLayout> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? currentUser;
  Stream<QuerySnapshot>? emailStream;

  @override
  void initState() {
    super.initState();
    _setCurrentUser();
  }

  Future<void> _setCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUser = user;
        // Fetch the emails of the logged-in user
        emailStream = _firestore
            .collection('Users')
            .doc('Students')
            .collection('CUT')
            .doc(user.uid)
            .collection('Emails')
            .orderBy('timestamp', descending: true)
            .snapshots();
      });
    }
  }

  void _showBottomSheet(String subject, String body) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.95,
          minChildSize: 0.8,
          maxChildSize: 0.95,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: ListView(
                children: [
                  ListTile(
                    title: Text(
                      subject,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(body),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitRipple(
            color: Colors.orange,
            size: SizeConfig.width(15), // equivalent to 60.0
          ),
          SizedBox(height: SizeConfig.height(2)), // equivalent to 16
          Text(
            'Loading emails...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: SizeConfig.text(5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.email_outlined,
            size: SizeConfig.width(20), // equivalent to 80
            color: Colors.grey[400],
          ),
          SizedBox(height: SizeConfig.height(2)),
          Text(
            'No emails sent yet',
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: SizeConfig.text(4.5),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: SizeConfig.height(1)),
          Text(
            'Tap the + button to compose an email',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: SizeConfig.text(3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: SizeConfig.width(20),
            color: Colors.red[400],
          ),
          SizedBox(height: SizeConfig.height(2)),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: SizeConfig.text(2.5),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: SizeConfig.height(1)),
          Text(
            'Please try again later',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: SizeConfig.text(2),
            ),
          ),
          SizedBox(height: SizeConfig.height(3)),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _setCurrentUser(); // Refresh the emails
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.width(6),
                vertical: SizeConfig.height(1.5),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SizeConfig.width(7.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return currentUser == null
        ? _buildLoadingState(context)
        : Stack(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: emailStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _buildErrorState(context);
                  }
                  if (!snapshot.hasData) {
                    return _buildLoadingState(context);
                  }
                  if (snapshot.data!.docs.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  var emails = snapshot.data!.docs;

                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListView.separated(
                      itemCount: emails.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        var emailData =
                            emails[index].data() as Map<String, dynamic>;
                        String sender =
                            emailData['recipient_email'] ?? 'No Sender';
                        String subject = emailData['subject'] ?? 'No Subject';
                        String body = emailData['body'] ?? 'No Content';
                        Timestamp? timestamp =
                            emailData['timestamp'] as Timestamp?;
                        DateTime emailDate =
                            timestamp?.toDate() ?? DateTime.now();
                        String formattedDate = _formatMessageDate(emailDate);
                        bool isSelected =
                            widget.selectedEmails.contains(emails[index].id);

                        return ListTile(
                          selected: isSelected,
                          selectedTileColor: Colors.orange.withOpacity(0.1),
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange,
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.white)
                                : Text(sender[0].toUpperCase(),
                                    style:
                                        const TextStyle(color: Colors.white)),
                          ),
                          title: Text(
                            sender,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                subject,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                body,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          trailing: Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          onTap: () {
                            if (widget.selectedEmails.isNotEmpty) {
                              _toggleSelection(emails[index].id);
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EmailDetailPage(
                                    recipientEmail: sender,
                                    subject: subject,
                                    body: body,
                                    timestamp: timestamp ?? Timestamp.now(),
                                  ),
                                ),
                              );
                            }
                          },
                          onLongPress: () {
                            _toggleSelection(emails[index].id);
                          },
                        );
                      },
                    ),
                  );
                },
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton(
                  backgroundColor: Colors.orange,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ComposeEmailLayout(),
                      ),
                    );
                  },
                  tooltip: 'Add Email',
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          );
  }

  String _formatMessageDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM dd').format(dateTime);
    }
  }

  void _toggleSelection(String emailId) {
    final newSelection = Set<String>.from(widget.selectedEmails);
    if (newSelection.contains(emailId)) {
      newSelection.remove(emailId);
    } else {
      newSelection.add(emailId);
    }
    widget.onSelectedEmailsChanged(newSelection);
    widget.onSelectionModeChanged(newSelection.isNotEmpty);
  }
}
