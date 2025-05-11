// 감정된 예약 확인 페이지 구현
import 'dart:async';
import 'package:app/models/reserve_data.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; // Added import for DateFormat
import 'package:flutter/services.dart'; // TextInputFormatter 사용을 위해 추가
import 'dart:math'; // min 함수 사용을 위해 추가

class ReservationConfirmPage extends StatefulWidget {
  final int businessId; // ✅ 추가
  final DateTime date;
  final String time;
  final int people;
  final String storeName; // ✅ 변수 선언

  const ReservationConfirmPage({
    required this.businessId,
    required this.date,
    required this.time,
    required this.people,
    required this.storeName, // ✅ this.storeName 사용
  });

  @override
  State<ReservationConfirmPage> createState() => _ReservationConfirmPageState();
}

class _ReservationConfirmPageState extends State<ReservationConfirmPage> {
  Duration remaining = const Duration(minutes: 100);
  Timer? timer;

  List<String> selectedPurposes = [];
  final List<String> allPurposes = [
    '최립',
    '가족식사',
    '여행',
    '생일',
    '기념일',
    '비즈니스미팅',
    '회식',
    '단체모임',
    '기타',
  ];

  final TextEditingController requestController = TextEditingController();
  bool agreedPrivacy = false;
  List<bool> checkedCautions = [false, false, false];

  List<Map<String, String>> visitors = [];

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remaining.inSeconds <= 1) {
        t.cancel();
        Navigator.pop(context);
      } else {
        setState(() => remaining -= const Duration(seconds: 1));
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    requestController.dispose();
    super.dispose();
  }

  bool get allCautionsChecked => checkedCautions.every((c) => c);

  void _showVisitorBottomSheet() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  '방문자 정보 입력',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('방문자 성함', style: TextStyle(color: Colors.black)),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: '이름을 입력하세요',
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 12),
              const Text('방문자 연락체', style: TextStyle(color: Colors.black)),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                  _PhoneNumberFormatter(),
                ],
                decoration: const InputDecoration(
                  hintText: '전화번호를 입력하세요',
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        phoneController.text.isNotEmpty) {
                      setState(() {
                        visitors.add({
                          'name': nameController.text,
                          'phone': phoneController.text,
                        });
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    '저장',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  String convertTo24HourTime(String timeStr) {
    final isPm = timeStr.contains('오후');
    final cleaned = timeStr.replaceAll(RegExp(r'[^\d:]'), '');
    final parts = cleaned.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    if (isPm && hour != 12) hour += 12;
    if (!isPm && hour == 12) hour = 0;

    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final String reservationInfo =
        '${widget.date.month}월 ${widget.date.day}일 · ${widget.time} · ${widget.people}명';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, // 항상 흰색 유지
        elevation: 0.5,
        centerTitle: false,
        title: Text(
          widget.storeName,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              '${remaining.inMinutes.remainder(60).toString().padLeft(2, '0')}:${remaining.inSeconds.remainder(60).toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        foregroundColor: Colors.black,
        surfaceTintColor: Colors.white,
        shadowColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 90),
            child: ListView(
              padding: const EdgeInsets.all(0),
              children: [
                // 예약 정보 카드
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                  padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.deepOrange, size: 20),
                          SizedBox(width: 8),
                          Text(
                            reservationInfo,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.blue, size: 20),
                          SizedBox(width: 8),
                          Text('${widget.people}명', style: TextStyle(fontSize: 15)),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.green, size: 20),
                          SizedBox(width: 8),
                          Text(widget.time, style: TextStyle(fontSize: 15)),
                        ],
                      ),
                    ],
                  ),
                ),
                // 방문자 정보
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: OutlinedButton(
                    onPressed: _showVisitorBottomSheet,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    child: const Text(
                      '다른 사람이 방문해요',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // 방문 목적
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _sectionTitle('방문 목적', sub: '복수 선택 가능'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: allPurposes.map((purpose) {
                      final selected = selectedPurposes.contains(purpose);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (selected) {
                              selectedPurposes.remove(purpose);
                            } else {
                              selectedPurposes.add(purpose);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: selected ? Colors.black : Colors.white,
                            border: Border.all(
                              color: selected ? Colors.black : Color(0xFFD2D2D2),
                              width: 1.2,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            purpose,
                            style: TextStyle(
                              color: selected ? Colors.white : Color(0xFF999999),
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                // 유의사항
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _sectionTitle('메장 유의사항'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      _checkItem(0, '[필수] 예약해도 대기시간이 발생할 수 있습니다.'),
                      _checkItem(1, '[필수] 룸 예약은 전화로만 가능합니다.'),
                      _checkItem(2, '[필수] 아이용 식기/의자는 요청사항에 적어주세요.'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // 요청사항
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _sectionTitle('고객 요청사항'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: requestController,
                    decoration: const InputDecoration(
                      hintText: '메장에 요청할 내용을 작성해주세요.',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color(0xFFF8F8F8),
                    ),
                    maxLines: 3,
                  ),
                ),
                const SizedBox(height: 24),
                // 개인정보 동의
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: agreedPrivacy,
                          onChanged: (val) {
                            setState(() => agreedPrivacy = val ?? false);
                          },
                          activeColor: Colors.black,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: const VisualDensity(
                            horizontal: -4,
                            vertical: -4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '개인정보 제3자 제공 동의',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 120),
              ],
            ),
          ),
          // 하단 예약하기 버튼
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('예약 정보', style: TextStyle(color: Colors.grey)),
                  Text(
                    reservationInfo,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed:
                        (allCautionsChecked && agreedPrivacy)
                            ? () async {
                              final formattedNow = DateFormat(
                                'yyyy-MM-dd HH:mm:ss',
                              ).format(DateTime.now());
                              final formattedTime = convertTo24HourTime(
                                widget.time,
                              ); // "오후 2:30" → "14:30"

                              final reserveData = reserve_data(
                                bId: widget.businessId,
                                date:
                                    '${widget.date.year}-${widget.date.month.toString().padLeft(2, '0')}-${widget.date.day.toString().padLeft(2, '0')}',
                                time: formattedTime, // ✅ 여기 수정
                                count: widget.people,
                                rTime: formattedNow, // 현재 시각을 포맷된 문자열로
                                status: 'standby',
                                uuid:
                                    Supabase
                                        .instance
                                        .client
                                        .auth
                                        .currentUser
                                        ?.id ??
                                    '',
                                comment: requestController.text,
                              );

                              try {
                                await Supabase.instance.client
                                    .from('reserve_data')
                                    .insert(reserveData.toJson());

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('예약이 저장되었습니다.')),
                                );
                                Navigator.pop(context);
                              } catch (e) {
                                print('예약 저장 실패: $e');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('예약 저장에 실패했습니다.'),
                                  ),
                                );
                              }
                            }
                            : null,

                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      disabledForegroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('예약하기'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, {String? sub}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        if (sub != null) ...[
          const SizedBox(width: 8),
          Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ],
    );
  }

  Widget _checkItem(int index, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0).copyWith(left: 10),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: checkedCautions[index],
              onChanged: (val) {
                setState(() {
                  checkedCautions[index] = val ?? false;
                });
              },
              activeColor: Colors.black,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    final buffer = StringBuffer();
    
    if (text.length > 0) {
      buffer.write(text.substring(0, min(3, text.length)));
      if (text.length > 3) {
        buffer.write('-');
        buffer.write(text.substring(3, min(7, text.length)));
        if (text.length > 7) {
          buffer.write('-');
          buffer.write(text.substring(7, min(11, text.length)));
        }
      }
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
