class UserProfile {
  final String uid;
  final String email;
  final String? name;
  final String? photoPath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? preferences;

  UserProfile({
    required this.uid,
    required this.email,
    this.name,
    this.photoPath,
    required this.createdAt,
    required this.updatedAt,
    this.preferences,
  });

  /// Construtor para criar perfil a partir do Firebase Auth
  factory UserProfile.fromAuth({
    required String uid,
    required String email,
    String? name,
  }) {
    final now = DateTime.now();
    return UserProfile(
      uid: uid,
      email: email,
      name: name,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Converter para Map para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'photoPath': photoPath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'preferences': preferences ?? {},
    };
  }

  /// Criar instância a partir de Map do Firestore
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'],
      photoPath: map['photoPath'],
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
      preferences: map['preferences'] != null
          ? Map<String, dynamic>.from(map['preferences'])
          : null,
    );
  }

  /// Criar cópia com alterações
  UserProfile copyWith({
    String? uid,
    String? email,
    String? name,
    String? photoPath,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? preferences,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      photoPath: photoPath ?? this.photoPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      preferences: preferences ?? this.preferences,
    );
  }

  /// Verificar se tem nome definido
  bool get hasName => name != null && name!.isNotEmpty;

  /// Verificar se tem foto
  bool get hasPhoto => photoPath != null && photoPath!.isNotEmpty;

  /// Obter nome de exibição
  String get displayName {
    if (hasName) return name!;
    return email.split('@').first; // Usar parte do email como fallback
  }

  /// Obter iniciais para avatar
  String get initials {
    if (hasName) {
      final parts = name!.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      }
      return name![0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  @override
  String toString() {
    return 'UserProfile(uid: $uid, email: $email, name: $name, hasPhoto: $hasPhoto)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.uid == uid &&
        other.email == email &&
        other.name == name &&
        other.photoPath == photoPath;
  }

  @override
  int get hashCode {
    return uid.hashCode ^ email.hashCode ^ name.hashCode ^ photoPath.hashCode;
  }
}
