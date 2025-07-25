/// User data model for the task manager app
/// 
/// Represents the app user with basic information for personalization
/// and user experience customization.
class User {
  /// User's display name for personalization
  final String name;
  
  /// Timestamp when the user first set up the app
  final DateTime createdAt;

  /// Creates a new User instance
  /// 
  /// [name] is required and should be the user's preferred display name
  /// [createdAt] tracks when the user first configured the app
  User({
    required this.name,
    required this.createdAt,
  }) : assert(name.trim().isNotEmpty, 'User name cannot be empty');

  /// Creates a copy of this user with optionally updated values
  /// 
  /// Useful for updating user information while maintaining immutability
  User copyWith({
    String? name,
    DateTime? createdAt,
  }) {
    return User(
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Converts the user to a JSON map for serialization
  /// 
  /// Used for data persistence and storage operations
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Creates a User instance from a JSON map
  /// 
  /// Used for deserializing data from storage
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// String representation of the user for debugging
  @override
  String toString() {
    return 'User(name: $name, createdAt: $createdAt)';
  }

  /// Equality comparison based on all properties
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is User &&
        other.name == name &&
        other.createdAt == createdAt;
  }

  /// Hash code based on all properties
  @override
  int get hashCode {
    return Object.hash(name, createdAt);
  }

  /// Helper method to get a personalized greeting
  String get greeting {
    final hour = DateTime.now().hour;
    String timeGreeting;
    
    if (hour < 12) {
      timeGreeting = 'Good morning';
    } else if (hour < 17) {
      timeGreeting = 'Good afternoon';
    } else {
      timeGreeting = 'Good evening';
    }
    
    return '$timeGreeting, $name!';
  }

  /// Helper method to get the user's first name
  String get firstName {
    return name.split(' ').first;
  }

  /// Helper method to check if user is new (created today)
  bool get isNewUser {
    final now = DateTime.now();
    return now.year == createdAt.year &&
           now.month == createdAt.month &&
           now.day == createdAt.day;
  }

  /// Helper method to get days since user joined
  int get daysSinceJoined {
    final now = DateTime.now();
    return now.difference(createdAt).inDays;
  }
}