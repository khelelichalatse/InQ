// Model class representing a user in the system

class UserData {
  final String uid;        // Unique identifier for the user
  final String name;       // User's full name
  final String email;      // User's email address
  final String studentId;  // Student identification number
  final String phoneNumber;// Contact number
  final String? imageUrl;  // Optional profile image URL

  UserData({
    required this.uid,
    required this.name,
    required this.email,
    required this.studentId,
    required this.phoneNumber,
    this.imageUrl,
  });

  // Add the copyWith method
  UserData copyWith({
    String? uid,
    String? name,
    String? studentId,
    String? phoneNumber,
    String? email,
    String? imageUrl,
  }) {
    return UserData(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      studentId: studentId ?? this.studentId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}