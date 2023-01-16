class UserInfo {
  late String createdAt;
  late String id;
  late String role;
  String? address;
  int? rating;

  UserInfo(
      {required this.createdAt,
      required this.id,
      required this.role,
      this.address,
      this.rating});

  UserInfo.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    id = json['id'];
    role = json['role'];
    address = json['address'];
    rating = json['rating'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['createdAt'] = createdAt;
    data['id'] = id;
    data['role'] = role;
    data['address'] = address;
    data['rating'] = rating;
    return data;
  }
}
