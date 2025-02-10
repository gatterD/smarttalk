class User {
  String userName;
  String password;

  User({required this.userName, required this.password});

  factory User.fronJson(Map<String, dynamic> json) {
    return User(userName: json['userName'], password: json['password']);
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'password': password,
    };
  }
}
