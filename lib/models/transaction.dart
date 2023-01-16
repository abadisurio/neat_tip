class Transaction {
  late String id;
  late String customerUserId;
  String? service;
  late String timeRequested;
  String? timeFinished;
  int? value;
  String? status;

  Transaction(
      {required this.id,
      required this.customerUserId,
      this.service,
      required this.timeRequested,
      this.timeFinished,
      this.value,
      this.status});

  Transaction.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customerUserId = json['customerUserId'];
    service = json['service'];
    timeRequested = json['timeRequested'];
    timeFinished = json['timeFinished'];
    value = json['value'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['customerUserId'] = customerUserId;
    data['service'] = service;
    data['timeRequested'] = timeRequested;
    data['timeFinished'] = timeFinished;
    data['value'] = value;
    data['status'] = status;
    return data;
  }
}
