import 'package:isar/isar.dart';

part 'models.g.dart';

@collection
class UserModel {
  Id id = Isar.autoIncrement;

  late String name;
  int age = 0;
  bool biometricEnabled = false;
}

@collection
class MedicineModel {
  Id id = Isar.autoIncrement;

  late String name;
  String dosage = '';
  List<DateTime> scheduleTimes = [];
  bool isActive = true;

  @Index()
  int? userId;
}
