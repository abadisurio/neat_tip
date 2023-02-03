class NeatTipUser {
  late String createdAt;
  late String updatedAt;
  late String id;
  late String role;
  late String displayName;
  String? address;
  int? rating;

  NeatTipUser(
      {required this.createdAt,
      required this.updatedAt,
      required this.id,
      required this.role,
      required this.displayName,
      this.address,
      this.rating});

  NeatTipUser.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    id = json['id'];
    role = json['role'];
    displayName = json['displayName'];
    address = json['address'];
    rating = json['rating'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['id'] = id;
    data['role'] = role;
    data['displayName'] = displayName;
    data['address'] = address;
    data['rating'] = rating;
    return data;
  }
}
