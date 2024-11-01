class UserData {
  final String uid;
  final String name;
  final String email;
  final String studentId;
  final String phoneNumber;
  final String? imageUrl;

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