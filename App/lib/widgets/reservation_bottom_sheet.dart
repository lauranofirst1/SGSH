import 'package:app/pages/reservationpage.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void showReservationBottomSheet(BuildContext context, {
  required String storeName,
  required int storeId, // ✅ 추가
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent, // 투명하게 해서 그림자 효과
    builder: (context) {
      DateTime focusedDay = DateTime.now();
      DateTime? selectedDay = DateTime.now();
      int? selectedPeople;
      String? selectedTime;

      // ✅ 과거 시간인지 확인하는 함수
      bool isPastTime(String timeStr, DateTime selectedDate) {
        final now = DateTime.now();

        final isPm = timeStr.contains('오후');
        final parts = timeStr.replaceAll(RegExp(r'[^\d:]'), '').split(':');
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);

        if (isPm && hour != 12) hour += 12;
        if (!isPm && hour == 12) hour = 0;

        final time = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          hour,
          minute,
        );

        return selectedDate.year == now.year &&
            selectedDate.month == now.month &&
            selectedDate.day == now.day &&
            time.isBefore(now);
      }

      return StatefulBuilder(
        builder: (context, setState) {
          final isComplete = selectedDay != null && selectedPeople != null && selectedTime != null;
          return Center(
            child: Container(
              margin: const EdgeInsets.only(top: 60, bottom: 20),
              constraints: BoxConstraints(
                maxWidth: 420,
                minWidth: 0,
                maxHeight: MediaQuery.of(context).size.height * 0.92,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 30,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. 드래그바 (고정)
                  Center(
                    child: Container(
                      width: 48,
                      height: 6,
                      margin: const EdgeInsets.only(top: 24, bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  // 2. 예약 폼 (스크롤)
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 날짜 선택
                          Container(
                            padding: EdgeInsets.all(16),
                            margin: EdgeInsets.only(bottom: 18),
                              decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                          const Text(
                            '날짜 선택',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                                SizedBox(height: 8),
                          TableCalendar(
                                  firstDay: DateTime.now(),
                            lastDay: DateTime.utc(2030, 12, 31),
                            focusedDay: focusedDay,
                            selectedDayPredicate:
                                (day) => isSameDay(selectedDay, day),
                            onDaySelected: (selected, focused) {
                              setState(() {
                                selectedDay = selected;
                                focusedDay = focused;
                              });
                            },
                            enabledDayPredicate: (day) {
                              final now = DateTime.now();
                              final today = DateTime(
                                now.year,
                                now.month,
                                now.day,
                              );
                              return !day.isBefore(today);
                            },
                            calendarStyle: const CalendarStyle(
                              todayDecoration: BoxDecoration(
                                color: Color.fromARGB(255, 183, 183, 183),
                                shape: BoxShape.circle,
                              ),
                              selectedDecoration: BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                            ),
                            headerStyle: const HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                            ),
                          ),
                              ],
                            ),
                          ),
                          // 인원 선택
                          Container(
                            padding: EdgeInsets.all(16),
                            margin: EdgeInsets.only(bottom: 18),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                          const Text(
                            '인원 선택',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                                SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(7, (index) {
                                final int people = index + 1;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  child: ChoiceChip(
                                    label: Text(
                                      '$people명',
                                      style: TextStyle(
                                        color:
                                            selectedPeople == people
                                                ? Colors.white
                                                : Colors.black,
                                      ),
                                    ),
                                    selected: selectedPeople == people,
                                    selectedColor: Colors.black,
                                    backgroundColor: Colors.white,
                                    checkmarkColor: Colors.white,
                                    onSelected: (_) {
                                      setState(() {
                                        selectedPeople = people;
                                      });
                                    },
                                  ),
                                );
                              }),
                            ),
                          ),
                              ],
                            ),
                          ),
                          // 시간 선택
                          Container(
                            padding: EdgeInsets.all(16),
                            margin: EdgeInsets.only(bottom: 18),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                          const Text(
                            '시간 선택',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                                SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children:
                                  [
                                     '오전 8:00',
                                      '오전 9:00',
                                       '오전 10:00',
                                    '오전 11:00',
                                    '오전 11:30',
                                    '오후 12:00',
                                    '오후 12:30',
                                    '오후 1:00',
                                    '오후 2:00',
                                     '오후 3:00',
                                    '오후 4:00',
                                     '오후 5:00',
                                    '오후 6:00',
                                     '오후 7:00',
                                    '오후 8:00',
                                     '오후 9:00',
                                    
                                  ].map((time) {
                                    final isSelected = selectedTime == time;
                                    final isDisabled =
                                        selectedDay != null &&
                                        isPastTime(time, selectedDay!);

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0,
                                      ),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              isSelected
                                                  ? Colors.black
                                                  : Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 10,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            side: BorderSide(
                                              color: Colors.black12,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                        onPressed:
                                            isDisabled
                                                ? null
                                                : () {
                                                  setState(() {
                                                    selectedTime = time;
                                                  });
                                                },
                                        child: Text(
                                          time,
                                          style: TextStyle(
                                            color:
                                                isDisabled
                                                    ? Colors.grey
                                                    : (isSelected
                                                        ? Colors.white
                                                        : Colors.black),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                  // 3. 예약 정보 요약 + 예약하기 버튼 (고정)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Builder(
                      builder: (context) {
                        List<String> infoParts = [];
                        if (selectedDay != null) {
                          infoParts.add('${selectedDay!.year}년 ${selectedDay!.month.toString().padLeft(2, '0')}월 ${selectedDay!.day.toString().padLeft(2, '0')}일');
                        }
                        if (selectedPeople != null) {
                          infoParts.add('${selectedPeople}명');
                        }
                        if (selectedTime != null) {
                          infoParts.add('$selectedTime시');
                        }
                        String info = infoParts.join(' · ');
                        return info.isNotEmpty
                            ? Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  info,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : SizedBox(height: 0);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            isComplete
                                ? () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => ReservationConfirmPage(
                                            date: selectedDay!,
                                            time: selectedTime!,
                                            people: selectedPeople!,
                                            storeName: storeName, 
  businessId: storeId, // ✅ 수정
                                          ),
                                    ),
                                  );
                                }
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isComplete ? Colors.black : Colors.grey.shade300,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          '예약하기',
                          style: TextStyle(
                            color: isComplete ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
