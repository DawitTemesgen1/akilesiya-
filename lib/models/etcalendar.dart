import 'package:flutter/material.dart';
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
        print("Invalid date format for EthiopianDate.parse: $formattedString");
        return EthiopianDate.now();
      }
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      return EthiopianDate(year: year, month: month, day: day);
    } catch (e) {
      print("Error parsing Ethiopian date string: $formattedString. Error: $e");
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

  @override
  String toString() {
    if (month < 1 || month > 13) return "Invalid Date";
    return '${monthNames[month - 1]} $day, $year';
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

  void _changeYear(int amount) {
    setState(() {
      _selectedYear += amount;
      final daysInMonth =
          EthiopianDate(year: _selectedYear, month: _selectedMonth, day: 1)
              .daysInMonth;
      if (_selectedDay > daysInMonth) {
        _selectedDay = daysInMonth;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tempDate =
        EthiopianDate(year: _selectedYear, month: _selectedMonth, day: 1);
    final daysInMonth = tempDate.daysInMonth;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('📅 Select Date',
                  style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        icon:
                            const Icon(Icons.chevron_left, color: primaryColor),
                        onPressed: () => _changeYear(-1)),
                    Text('$_selectedYear E.C.',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: primaryColor)),
                    IconButton(
                        icon: const Icon(Icons.chevron_right,
                            color: primaryColor),
                        onPressed: () => _changeYear(1)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12)),
                child: DropdownButton<int>(
                  value: _selectedMonth,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: List.generate(
                      13,
                      (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text(EthiopianDate.monthNames[index],
                              style: GoogleFonts.poppins(fontSize: 14)))),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedMonth = value;
                        final newDaysInMonth = EthiopianDate(
                                year: _selectedYear,
                                month: _selectedMonth,
                                day: 1)
                            .daysInMonth;
                        if (_selectedDay > newDaysInMonth) {
                          _selectedDay = newDaysInMonth;
                        }
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8),
                  itemCount: daysInMonth,
                  itemBuilder: (context, index) {
                    final day = index + 1;
                    final isSelected = day == _selectedDay;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDay = day),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? primaryColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: isSelected
                                  ? primaryColor
                                  : Colors.grey.shade300),
                        ),
                        child: Text('$day',
                            style: GoogleFonts.poppins(
                                color:
                                    isSelected ? Colors.white : onSurfaceColor,
                                fontWeight: FontWeight.w600)),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                      child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Cancel', style: GoogleFonts.poppins()))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      onPressed: () => Navigator.of(context).pop(EthiopianDate(
                          year: _selectedYear,
                          month: _selectedMonth,
                          day: _selectedDay)),
                      child: Text('Select', style: GoogleFonts.poppins()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
