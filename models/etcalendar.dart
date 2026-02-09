class EthiopianDateConverter {
  // Ethiopian calendar constants
  static const int _ethiopianEra = 8;
  static const int _gregorianEra = 1723856;
  static const List<int> _ethiopianMonths = [
    30,
    30,
    30,
    30,
    30,
    30,
    30,
    30,
    30,
    30,
    30,
    30,
    5,
  ];
  static const List<int> _ethiopianMonthDaysLeap = [
    30,
    30,
    30,
    30,
    30,
    30,
    30,
    30,
    30,
    30,
    30,
    30,
    6,
  ];

  // Convert Gregorian to Ethiopian date
  static EthiopianDate fromGregorian(DateTime gregorianDate) {
    int day = gregorianDate.day;
    int month = gregorianDate.month;
    int year = gregorianDate.year;

    // Calculate Julian Day Number
    int a = (14 - month) ~/ 12;
    int y = year + 4800 - a;
    int m = month + 12 * a - 3;
    int jdn =
        day +
        ((153 * m + 2) ~/ 5) +
        365 * y +
        (y ~/ 4) -
        (y ~/ 100) +
        (y ~/ 400) -
        32045;

    // Convert to Ethiopian date
    int jdnOffset = jdn - _gregorianEra;
    int ethYear = (jdnOffset / 365.25).floor() + _ethiopianEra;
    int ethDayOfYear = jdnOffset - ((ethYear - _ethiopianEra) * 365.25).floor();

    bool isLeap = _isEthiopianLeapYear(ethYear);
    List<int> monthDays = isLeap ? _ethiopianMonthDaysLeap : _ethiopianMonths;

    int ethMonth = 1;
    int remainingDays = ethDayOfYear;

    while (remainingDays > monthDays[ethMonth - 1]) {
      remainingDays -= monthDays[ethMonth - 1];
      ethMonth++;
    }

    int ethDay = remainingDays;

    return EthiopianDate(year: ethYear, month: ethMonth, day: ethDay);
  }

  // Check if Ethiopian year is leap
  static bool _isEthiopianLeapYear(int year) {
    return (year % 4 == 3);
  }
}

class EthiopianDate {
  final int year;
  final int month;
  final int day;

  EthiopianDate({required this.year, required this.month, required this.day});

  @override
  String toString() {
    return '$year/${month.toString().padLeft(2, '0')}/${day.toString().padLeft(2, '0')}';
  }
}
