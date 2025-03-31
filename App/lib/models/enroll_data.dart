class enroll_data {
  final int id;
  final bool check;
  final String name;
  final String phone;
  final String businessName;
  final String address;
  final String time;
  final String image;

  enroll_data({
    required this.id,
    required this.check,
    required this.name,
    required this.phone,
    required this.businessName,
    required this.address,
    required this.time,
    required this.image,
  });

  factory enroll_data.fromMap(Map<String, dynamic> data) {
    return enroll_data(
      id: data['id'] as int,
      check: data['check'] as bool,
      name: data['name'] as String,
      phone: data['phone'] as String,
      businessName: data['business_name'] as String,
      address: data['address'] as String,
      time: data['time'] as String,
      image: data['image'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'check': check,
      'name': name,
      'phone': phone,
      'business_name': businessName,
      'address': address,
      'time': time,
      'image': image,
    };
  }
}
