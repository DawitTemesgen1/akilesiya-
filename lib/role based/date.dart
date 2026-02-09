// import 'package:amde_haymanot_abalat_guday/models/etcalendar.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// // --- Re-usable UI Constants ---
// const Color primaryColor = Color.fromARGB(255, 1, 37, 100);
// const Color onSurfaceColor = Color(0xFF212529);

// // ===============================================================
// // SHARED WIDGET: EthiopianDatePickerDialog
// // ===============================================================
// class EthiopianDatePickerDialog extends StatefulWidget {
//   final EthiopianDate initialDate;
//   const EthiopianDatePickerDialog({super.key, required this.initialDate});

//   @override
//   State<EthiopianDatePickerDialog> createState() =>
//       _EthiopianDatePickerDialogState();
// }

// class _EthiopianDatePickerDialogState extends State<EthiopianDatePickerDialog> {
//   late int _selectedYear;
//   late int _selectedMonth;
//   late int _selectedDay;

//   @override
//   void initState() {
//     super.initState();
//     _selectedYear = widget.initialDate.year;
//     _selectedMonth = widget.initialDate.month;
//     _selectedDay = widget.initialDate.day;
//   }

//   void _changeYear(int amount) {
//     setState(() {
//       _selectedYear += amount;
//       final daysInMonth =
//           EthiopianDate(year: _selectedYear, month: _selectedMonth, day: 1)
//               .daysInMonth;
//       if (_selectedDay > daysInMonth) {
//         _selectedDay = daysInMonth;
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final tempDate =
//         EthiopianDate(year: _selectedYear, month: _selectedMonth, day: 1);
//     final daysInMonth = tempDate.daysInMonth;

//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//       backgroundColor: Colors.transparent,
//       child: Container(
//         decoration: BoxDecoration(
//             color: Colors.white, borderRadius: BorderRadius.circular(24)),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text('📅 Select Date',
//                   style: GoogleFonts.poppins(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: primaryColor)),
//               const SizedBox(height: 20),
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                     color: primaryColor.withValues(alpha: 0.1),
//                     borderRadius: BorderRadius.circular(16)),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     IconButton(
//                         icon:
//                             const Icon(Icons.chevron_left, color: primaryColor),
//                         onPressed: () => _changeYear(-1)),
//                     Text('$_selectedYear E.C.',
//                         style: GoogleFonts.poppins(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18,
//                             color: primaryColor)),
//                     IconButton(
//                         icon: const Icon(Icons.chevron_right,
//                             color: primaryColor),
//                         onPressed: () => _changeYear(1)),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//                 decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey.shade300),
//                     borderRadius: BorderRadius.circular(12)),
//                 child: DropdownButton<int>(
//                   value: _selectedMonth,
//                   isExpanded: true,
//                   underline: const SizedBox(),
//                   items: List.generate(
//                       13,
//                       (index) => DropdownMenuItem(
//                           value: index + 1,
//                           child: Text(EthiopianDate.monthNames[index],
//                               style: GoogleFonts.poppins(fontSize: 14)))),
//                   onChanged: (value) {
//                     if (value != null) {
//                       setState(() {
//                         _selectedMonth = value;
//                         final newDaysInMonth = EthiopianDate(
//                                 year: _selectedYear,
//                                 month: _selectedMonth,
//                                 day: 1)
//                             .daysInMonth;
//                         if (_selectedDay > newDaysInMonth)
//                           _selectedDay = newDaysInMonth;
//                       });
//                     }
//                   },
//                 ),
//               ),
//               const SizedBox(height: 20),
//               SizedBox(
//                 height: 200,
//                 child: GridView.builder(
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 7,
//                       mainAxisSpacing: 8,
//                       crossAxisSpacing: 8),
//                   itemCount: daysInMonth,
//                   itemBuilder: (context, index) {
//                     final day = index + 1;
//                     final isSelected = day == _selectedDay;
//                     return GestureDetector(
//                       onTap: () => setState(() => _selectedDay = day),
//                       child: Container(
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                           color: isSelected ? primaryColor : Colors.transparent,
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(
//                               color: isSelected
//                                   ? primaryColor
//                                   : Colors.grey.shade300),
//                         ),
//                         child: Text('$day',
//                             style: GoogleFonts.poppins(
//                                 color:
//                                     isSelected ? Colors.white : onSurfaceColor,
//                                 fontWeight: FontWeight.w600)),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               const SizedBox(height: 24),
//               Row(
//                 children: [
//                   Expanded(
//                       child: OutlinedButton(
//                           onPressed: () => Navigator.of(context).pop(),
//                           child: Text('Cancel', style: GoogleFonts.poppins()))),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                           backgroundColor: primaryColor,
//                           foregroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12))),
//                       onPressed: () => Navigator.of(context).pop(EthiopianDate(
//                           year: _selectedYear,
//                           month: _selectedMonth,
//                           day: _selectedDay)),
//                       child: Text('Select', style: GoogleFonts.poppins()),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
