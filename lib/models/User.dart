class User {
  String? fullname;
  String? email;
  String? password;
  String? confirmPassword;

  User({
    this.fullname,
    this.email,
    this.password,
    this.confirmPassword,
  });

  // Factory constructor to create a User object from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      fullname: json['fullname'],
      email: json['email'],
      password: json['password'],
      confirmPassword: json['confirmPassword'],
    );
  }

  // Method to convert User object to JSON
  Map<String, dynamic> toJson() {
    return {
      'fullname': fullname,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
    };
  }
}