class User {
  String? fullname;
  String? email;

  User({
    this.fullname,
    this.email,
  });

  // Factory constructor to create a User object from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      fullname: json['fullname'],
      email: json['email'],
    );
  }

  // Method to convert User object to JSON
  Map<String, dynamic> toJson() {
    return {
      'fullname': fullname,
      'email': email,
    };
  }
}