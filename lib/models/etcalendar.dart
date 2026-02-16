import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Re-usable UI Constants ---
const Color primaryColor = Color.fromARGB(255, 1, 37, 100);
const Color onSurfaceColor = Color(0xFF212529);

// ===============================================================
// MAIN CLASS: EthiopianDate
// ===============================================================
class EthiopianDate {
  final int year;
  final int month;
  final int day;

  const EthiopianDate(
      {required this.year, required this.month, required this.day});

  factory EthiopianDate.now() {
    return EthiopianDate.fromGregorian(DateTime.now());
  }

  factory EthiopianDate.parse(String formattedString) {
    try {
      final parts = formattedString.split('T')[0].split('-');
      if (parts.length != 3) {
        developer.log(
            "Invalid date format for EthiopianDate.parse: $formattedString",
            name: 'EthiopianDate');
        return EthiopianDate.now();
      }
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      return EthiopianDate(year: year, month: month, day: day);
    } catch (e) {
      developer.log(
          "Error parsing Ethiopian date string: $formattedString. Error: $e",
          name: 'EthiopianDate',
          error: e);
      return EthiopianDate.now();
    }
  }

  factory EthiopianDate.fromGregorian(DateTime gregorianDate) {
    final jdn = _gregorianToJDN(
        gregorianDate.year, gregorianDate.month, gregorianDate.day);
    return _jdnToEthiopian(jdn);
  }

  DateTime toGregorian() {
    final jdn = _ethiopianToJDN(year, month, day);
    return _jdnToGregorian(jdn);
  }

  String toDatabaseString() {
    return "${year.toString()}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
  }

  bool get isLeapYear => (year % 4) == 3;

  int get daysInMonth {
    if (month == 13) return isLeapYear ? 6 : 5;
    return 30;
  }

  static const List<String> monthNamesAmharic = [
    'መስከረም',
    'ጥቅምት',
    'ኅዳር',
    'ታኅሣሥ',
    'ጥር',
    'የካቲት',
    'መጋቢት',
    'ሚያዝያ',
    'ግንቦት',
    'ሰኔ',
    'ሐምሌ',
    'ነሐሴ',
    'ጳጉሜ'
  ];

  static const List<String> weekdayNamesAmharic = [
    'ሰኞ',
    'ማክሰኞ',
    'ረቡዕ',
    'ሐሙስ',
    'ዓርብ',
    'ቅዳሜ',
    'እሑድ'
  ];

  @override
  String toString() {
    if (month < 1 || month > 13) return "Invalid Date";
    return '${monthNamesAmharic[month - 1]} $day, $year';
  }

  static const List<String> monthNames = [
    'Meskerem',
    'Tikimt',
    'Hidar',
    'Tahsas',
    'Tir',
    'Yekatit',
    'Megabit',
    'Miyazya',
    'Ginbot',
    'Sene',
    'Hamle',
    'Nehase',
    'Pagume'
  ];

  static const int _jdnOffset = 1723856;

  static EthiopianDate _jdnToEthiopian(int jdn) {
    int r = (jdn - _jdnOffset) % 1461;
    int n = (r % 365) + 365 * (r ~/ 1460);
    int year = 4 * ((jdn - _jdnOffset) ~/ 1461) + (r ~/ 365) - (r ~/ 1460);
    int month = (n ~/ 30) + 1;
    int day = (n % 30) + 1;
    return EthiopianDate(year: year, month: month, day: day);
  }

  static int _ethiopianToJDN(int year, int month, int day) {
    return (_jdnOffset - 1) +
        365 * year +
        ((year + 3) ~/ 4) +
        30 * (month - 1) +
        day;
  }

  static int _gregorianToJDN(int year, int month, int day) {
    int a = (14 - month) ~/ 12;
    int y = year + 4800 - a;
    int m = month + 12 * a - 3;
    return day +
        ((153 * m + 2) ~/ 5) +
        365 * y +
        (y ~/ 4) -
        (y ~/ 100) +
        (y ~/ 400) -
        32045;
  }

  static DateTime _jdnToGregorian(int jdn) {
    int a = jdn + 32044;
    int b = (4 * a + 3) ~/ 146097;
    int c = a - (146097 * b) ~/ 4;
    int d = (4 * c + 3) ~/ 1461;
    int e = c - (1461 * d) ~/ 4;
    int m = (5 * e + 2) ~/ 153;
    int day = e - (153 * m + 2) ~/ 5 + 1;
    int month = m + 3 - 12 * (m ~/ 10);
    int year = 100 * b + d - 4800 + (m ~/ 10);
    return DateTime(year, month, day);
  }
}

// ===============================================================
// SHARED WIDGET: EthiopianDatePickerDialog
// ===============================================================
class EthiopianDatePickerDialog extends StatefulWidget {
  final EthiopianDate initialDate;
  const EthiopianDatePickerDialog({super.key, required this.initialDate});

  @override
  State<EthiopianDatePickerDialog> createState() =>
      _EthiopianDatePickerDialogState();
}

class _EthiopianDatePickerDialogState extends State<EthiopianDatePickerDialog> {
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
    _selectedDay = widget.initialDate.day;
  }

  int _getFirstDayOfWeek() {
    // We calculate the weekday of the 1st day of the selected month
    final firstOfMonthGregorian =
        EthiopianDate(year: _selectedYear, month: _selectedMonth, day: 1)
            .toGregorian();
    // DateTime.weekday returns 1 for Monday, 7 for Sunday.
    return firstOfMonthGregorian.weekday;
  }

  @override
  Widget build(BuildContext context) {
    final tempDate =
        EthiopianDate(year: _selectedYear, month: _selectedMonth, day: 1);
    final daysInMonth = tempDate.daysInMonth;
    final firstDayOfWeek = _getFirstDayOfWeek(); // 1-7 (Mon-Sun)

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: const Color(0xFF151522), // Matching kCardColor
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                color: primaryColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ቀኑን ይምረጡ',
                      style: GoogleFonts.notoSansEthiopic(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          EthiopianDate(
                                  year: _selectedYear,
                                  month: _selectedMonth,
                                  day: _selectedDay)
                              .toString(),
                          style: GoogleFonts.notoSansEthiopic(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(Icons.edit_calendar_rounded,
                            color: Colors.white70),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Year and Month Controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _selectedMonth,
                            isExpanded: true,
                            dropdownColor: const Color(0xFF1A1A2A),
                            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                                color: Colors.white70),
                            items: List.generate(
                              13,
                              (index) => DropdownMenuItem(
                                value: index + 1,
                                child: Text(
                                  EthiopianDate.monthNamesAmharic[index],
                                  style: GoogleFonts.notoSansEthiopic(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedMonth = value;
                                  final newDays = EthiopianDate(
                                          year: _selectedYear,
                                          month: _selectedMonth,
                                          day: 1)
                                      .daysInMonth;
                                  if (_selectedDay > newDays) {
                                    _selectedDay = newDays;
                                  }
                                });
                                HapticFeedback.selectionClick();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _selectedYear,
                            isExpanded: true,
                            dropdownColor: const Color(0xFF1A1A2A),
                            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                                color: Colors.white70),
                            items: List.generate(
                              201, // Years from 1900 to 2100
                              (index) {
                                final year = 1900 + index;
                                return DropdownMenuItem(
                                  value: year,
                                  child: Text(
                                    '$year',
                                    style: GoogleFonts.outfit(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              },
                            ),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedYear = value;
                                  final newDays = EthiopianDate(
                                          year: _selectedYear,
                                          month: _selectedMonth,
                                          day: 1)
                                      .daysInMonth;
                                  if (_selectedDay > newDays) {
                                    _selectedDay = newDays;
                                  }
                                });
                                HapticFeedback.selectionClick();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Weekday Headers
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: EthiopianDate.weekdayNamesAmharic.map((day) {
                    return SizedBox(
                      width: 40,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSansEthiopic(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.4),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              // Day Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  height: 240,
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                    ),
                    // We need empty placeholders for the start of the month
                    // DateTime.weekday: 1=Mon, ..., 7=Sun
                    itemCount: daysInMonth + (firstDayOfWeek - 1),
                    itemBuilder: (context, index) {
                      if (index < (firstDayOfWeek - 1)) {
                        return const SizedBox.shrink();
                      }
                      final day = index - (firstDayOfWeek - 1) + 1;
                      final isSelected = day == _selectedDay;
                      final isToday =
                          EthiopianDate.now().year == _selectedYear &&
                              EthiopianDate.now().month == _selectedMonth &&
                              EthiopianDate.now().day == day;

                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedDay = day);
                          HapticFeedback.lightImpact();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color:
                                isSelected ? primaryColor : Colors.transparent,
                            shape: BoxShape.circle,
                            border: isToday && !isSelected
                                ? Border.all(color: primaryColor, width: 1.5)
                                : null,
                          ),
                          child: Text(
                            '$day',
                            style: GoogleFonts.outfit(
                              color: isSelected
                                  ? Colors.white
                                  : (isToday ? primaryColor : onSurfaceColor),
                              fontWeight: isSelected || isToday
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const Divider(height: 1),
              // Actions
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'ይቅር',
                        style: GoogleFonts.notoSansEthiopic(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      onPressed: () => Navigator.of(context).pop(EthiopianDate(
                          year: _selectedYear,
                          month: _selectedMonth,
                          day: _selectedDay)),
                      child: Text(
                        'ይሁን',
                        style: GoogleFonts.notoSansEthiopic(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
