class Driver {
  final String firstName;
  final String lastName;
  final String regNumber;
  final String idNumber;
  final String carType;
  final String carModel;
  final double rating;

  Driver({
    required this.firstName,
    required this.lastName,
    required this.regNumber,
    required this.idNumber,
    required this.carType,
    required this.carModel,
    required this.rating
  });

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'regNumber': regNumber,
      'idNumber': idNumber,
      'carType': carType,
      'carModel': carModel,
      'rating' :rating
    };
  }
}