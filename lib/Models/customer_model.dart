class CustomerModel {
  String? _customerId;
  String? _firstName;
  String? _lastName;
  String? _phoneNum;

  CustomerModel();

  CustomerModel.New(this._customerId, this._firstName, this._lastName,
      this._phoneNum); // Getters and Setters
  String? get customerId => _customerId;
  set customerId(String? value) => _customerId = value;

  String? get firstName => _firstName;
  set firstName(String? value) => _firstName = value;

  String? get lastName => _lastName;
  set lastName(String? value) => _lastName = value;

  String? get phoneNum => _phoneNum;
  set phoneNum(String? value) => _phoneNum = value;

  // Convert a map to a CustomerModel object (fromMap)
  CustomerModel.fromMap(Map<String, dynamic> map) {
    _customerId = map['customerId'];
    _firstName = map['firstName'];
    _lastName = map['lastName'];
    _phoneNum = map['phoneNumber'];
  }

  // Convert a CustomerModel object to a map (toMap)
  Map<String, dynamic> toMap() {
    return {
      'customerId': _customerId,
      'firstName': _firstName,
      'lastName': _lastName,
      'phoneNumber': _phoneNum,
    };
  }
}