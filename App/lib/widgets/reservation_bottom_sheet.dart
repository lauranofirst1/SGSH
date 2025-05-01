import 'package:app/pages/reservationpage.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void showReservationBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      DateTime focusedDay = DateTime.now();
      DateTime? selectedDay = DateTime.now();
      int? selectedPeople;
      String? selectedTime;

      return StatefulBuilder(
        builder: (context, setState) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.75,
            maxChildSize: 0.95,
            minChildSize: 0.4,
            builder: (_, scrollController) {
              final isComplete = selectedDay != null &&
                  selectedPeople != null &&
                  selectedTime != null;

              return Stack(
                children: [
                  // 상단 콘텐츠
                  Padding(
                    padding: const EdgeInsets.only(bottom: 80), // 버튼 높이 확보
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// 드래그 바
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),

                          /// 날짜 선택
                          const Text(
                            '날짜 선택',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          TableCalendar(
                            firstDay: DateTime.utc(2020, 1, 1),
                            lastDay: DateTime.utc(2030, 12, 31),
                            focusedDay: focusedDay,
                            selectedDayPredicate: (day) =>
                                isSameDay(selectedDay, day),
                            onDaySelected: (selected, focused) {
                              setState(() {
                                selectedDay = selected;
                                focusedDay = focused;
                              });
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

                          const SizedBox(height: 20),

                          /// 인원 선택
                          const Text(
                            '인원 선택',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(7, (index) {
                                final int people = index + 1;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: ChoiceChip(
                                    label: Text(
                                      '$people명',
                                      style: TextStyle(
                                        color: selectedPeople == people
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

                          const SizedBox(height: 24),

                          /// 시간 선택
                          const Text(
                            '시간 선택',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                '오전 11:00',
                                '오전 11:30',
                                '오후 12:00',
                                '오후 12:30',
                                '오후 1:00',
                              ].map((time) {
                                final isSelected = selectedTime == time;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isSelected
                                          ? Colors.black
                                          : Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: BorderSide(color: Colors.black12),
                                      ),
                                      elevation: 0,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        selectedTime = time;
                                      });
                                    },
                                    child: Text(
                                      time,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),

                  /// 하단 예약하기 버튼
                  Positioned(
                    bottom: 20,
                    left: 16,
                    right: 16,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isComplete
                            ? () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReservationConfirmPage(
                                      date: selectedDay!,
                                      time: selectedTime!,
                                      people: selectedPeople!,
                                    ),
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isComplete ? Colors.black : Colors.grey.shade300,
                          padding: const EdgeInsets.symmetric(vertical: 10),
  
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          '예약하기',
                          style: TextStyle(
                            color: isComplete ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    },
  );
}
