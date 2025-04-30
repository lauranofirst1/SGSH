final List<Map<String, dynamic>> reservations = [
  {
    'id': 1,
    'storeName': '하이디라오 코엑스점',
    'category': '중식',
    'location': '코엑스',
    'date': '2025.05.18',
    'dayOfWeek': '일',
    'time': '오후 12:30',
    'people': 3,
    'dday': 18,
    'image': 'assets/images/dummy_image/sushi.png',
    'status': 'upcoming', // upcoming, completed, canceled
    'showInviteBanner': true,
  },
  {
    'id': 2,
    'storeName': '하이디라오 대학로점',
    'category': '중식',
    'location': '혜화',
    'date': '2025.04.06',
    'dayOfWeek': '일',
    'time': '오후 5:00',
    'people': 2,
    'dday': -3,
    'image': 'assets/images/dummy_image/sushi.png',
    'status': 'completed',
    'showInviteBanner': false,
  },

  {
    'id': 201,
    'storeName': '취소된 스시집',
    'category': '스시 · 일식',
    'location': '신사',
    'date': '2025.05.12',
    'dayOfWeek': '월',
    'time': '18:00',
    'people': 2,
    'image': 'assets/images/dummy_image/sushi.png',
    'status': 'canceled',  // ✅ 핵심
  },
  {
    'id': 202,
    'storeName': '노쇼된 브런치카페',
    'category': '브런치 · 카페',
    'location': '성수',
    'date': '2025.04.28',
    'dayOfWeek': '일',
    'time': '11:30',
    'people': 3,
    'image': 'assets/images/dummy_image/sushi.png',
    'status': 'canceled',  // ✅ 핵심
  },


];
