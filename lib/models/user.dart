class User {
  final String id;
  final String email;
  final String password;
  String? photoPath;
  String? name;

  User({
    required this.id,
    required this.email,
    required this.password,
    this.photoPath,
    this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'photoPath': photoPath,
      'name': name,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      photoPath: json['photoPath'],
      name: json['name'],
    );
  }

  User copyWith({
    String? email,
    String? password,
    String? photoPath,
    String? name,
  }) {
    return User(
      id: id,
      email: email ?? this.email,
      password: password ?? this.password,
      photoPath: photoPath ?? this.photoPath,
      name: name ?? this.name,
    );
  }
}
