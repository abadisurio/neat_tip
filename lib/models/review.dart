class Review {
  late String createdAt;
  late String id;
  late String senderId;
  String? headline;
  String? description;
  int? voteCount;
  String? imgSrcPhotos;
  String? votersId;

  Review(
      {required this.createdAt,
      required this.id,
      required this.senderId,
      this.headline,
      this.description,
      this.imgSrcPhotos,
      this.votersId,
      this.voteCount});

  Review.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    id = json['id'];
    senderId = json['senderId'];
    headline = json['headline'];
    description = json['description'];
    imgSrcPhotos = json['imgSrcPhotos'];
    imgSrcPhotos = json['votersId'];
    voteCount = json['voteCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['createdAt'] = createdAt;
    data['id'] = id;
    data['senderId'] = senderId;
    data['headline'] = headline;
    data['description'] = description;
    data['imgSrcPhotos'] = imgSrcPhotos;
    data['votersId'] = votersId;
    data['voteCount'] = voteCount;
    return data;
  }
}
