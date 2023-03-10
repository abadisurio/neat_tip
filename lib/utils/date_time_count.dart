Duration dateTimeCount(String stringISO8601start, String stringISO8601finish,
    {bool onlyDay = false}) {
  final start = DateTime.parse(stringISO8601start);
  final finish = DateTime.parse(stringISO8601finish);
  final difference = finish.difference(start);
  // final differenceInDate = DateTime.fromMillisecondsSinceEpoch(
  //         difference.inMilliseconds + start.millisecond,
  //         isUtc: true)
  //     .add(const Duration(hours: 1));
  // log('differenceInDate ${differenceInDate.day}');
  // String formatted = DateFormat(
  //         "d 'Hari'${onlyDay ? "" : " h 'Jam' m 'Menit' s 'Detik'"} ", 'id_ID')
  //     .format(differenceInDate);
  // // log('formatted $formatted');
  // // //
  return difference;
}
