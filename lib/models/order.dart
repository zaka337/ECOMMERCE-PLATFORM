class Order {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String shippingAddress;
  final double totalAmount;
  final DateTime orderDate;

  Order({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.shippingAddress,
    required this.totalAmount,
    required this.orderDate,
  });
}
