import 'package:floor/floor.dart';

@entity
class NeatTipNotification {
  @primaryKey
  late String createdAt;
  late String title;
  late String body;

  NeatTipNotification(
      {required this.createdAt, required this.body, required this.title});

  NeatTipNotification.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    title = json['title'];
    body = json['body'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['createdAt'] = createdAt;
    data['body'] = body;

    return data;
  }
}
