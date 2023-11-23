class UserLogs {
  UserLogs(
      {
      required this.title,
      required this.description,
      required this.image,
      required this.userEmail});
  final String title;
  final String image;
  final String description;
  final String userEmail;
  
  factory UserLogs.fromJson(Map<String, dynamic> json) {
    return UserLogs(
      title: json['title'] as String? ?? 'emptytitle',
      image: json['image'] as String? ?? '',
      description: json['description'] as String? ?? 'emptydesc',
      userEmail: json['user_email'] as String? ?? 'emptyEmail',
    );
  }
}
