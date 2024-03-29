class Users {
  String? name;
  String? email;
  String? userImage;
  String? createdAt;
  String? id;
  String? userDescription;
  Users({
    required this.name,
    required this.createdAt,
    required this.email,
    required this.id,
    required this.userImage,
    required this.userDescription,
  });
  Users.from_JSON(Map<String, dynamic> json) {
    email = json['email'];
    name = json['name'];
    id = json['id'];
    userImage = json['userImage'];
    createdAt = json['createdAt'].toString();
    userDescription = json['userDescription'].toString();
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['userImage'] = userImage;
    data['id'] = id;
    data['createdAt'] = createdAt;
    data['name'] = name;
    data['userDescription'] = userDescription;
    return data;
  }
}
