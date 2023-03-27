import 'package:floor/floor.dart';

@entity
class Record {
  @primaryKey
  late String id;
  late String plateNumber;
  late String imgSrc;
  String? timeCheckedIn;
  String? timeCheckedOut;
  String? note;

  Record(
      {required this.id,
      required this.plateNumber,
      required this.imgSrc,
      this.timeCheckedIn,
      this.timeCheckedOut,
      this.note});

  Record.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    plateNumber = json['plateNumber'];
    timeCheckedIn = json['timeCheckedIn'];
    imgSrc = json['imgSrc'];
    timeCheckedOut = json['timeCheckedOut'];
    note = json['note'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['plateNumber'] = plateNumber;
    data['timeCheckedIn'] = timeCheckedIn;
    data['imgSrc'] = imgSrc;
    data['timeCheckedOut'] = timeCheckedOut;
    data['note'] = note;
    return data;
  }
}
