class Store {
  final String id;
  final String ownerId; // Firebase Auth UID
  final String storeName;
  final String ownerName;
  final String email;
  final String phone;
  final String address;
  final String description;
  final DateTime createdAt;

  Store({
    required this.id,
    required this.ownerId,
    required this.storeName,
    required this.ownerName,
    required this.email,
    required this.phone,
    required this.address,
    required this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'ownerId': ownerId,
      'storeName': storeName,
      'ownerName': ownerName,
      'email': email,
      'phone': phone,
      'address': address,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Store.fromJson(String id, Map<String, dynamic> json) {
    return Store(
      id: id,
      ownerId: json['ownerId'] ?? '',
      storeName: json['storeName'] ?? '',
      ownerName: json['ownerName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

