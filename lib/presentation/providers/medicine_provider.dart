import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/notification_service.dart';
import '../../data/datasources/isar_service.dart';
import '../../data/models/models.dart';

final isarServiceProvider = Provider<IsarService>((ref) {
  throw UnimplementedError('isarServiceProvider must be overridden in main()');
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final medicineListProvider =
    StateNotifierProvider<MedicineListNotifier, List<MedicineModel>>((ref) {
  return MedicineListNotifier(
    ref.read(isarServiceProvider),
    ref.read(notificationServiceProvider),
  );
});

class MedicineListNotifier extends StateNotifier<List<MedicineModel>> {
  final IsarService _isar;
  final NotificationService _notifications;

  MedicineListNotifier(this._isar, this._notifications) : super([]) {
    _loadMedicines();
  }

  Future<void> _loadMedicines() async {
    state = await _isar.getAllMedicines();
  }

  Future<void> addMedicine(MedicineModel medicine) async {
    final id = await _isar.saveMedicine(medicine);
    medicine.id = id;
    state = [...state, medicine];
    await _notifications.scheduleForMedicine(medicine);
  }

  Future<void> deleteMedicine(int id) async {
    await _isar.deleteMedicine(id);
    state = state.where((m) => m.id != id).toList();
    await _notifications.cancelForMedicine(id);
  }
}
