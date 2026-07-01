import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth_service.dart';
import '../../core/notification_service.dart';
import '../../data/datasources/isar_service.dart';
import '../../data/models/models.dart';

final isarServiceProvider = Provider<IsarService>((ref) {
  throw UnimplementedError('isarServiceProvider must be overridden in main()');
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final authServiceProvider = Provider<AuthService>((ref) {
  throw UnimplementedError('authServiceProvider must be overridden in main()');
});

final userProvider = FutureProvider<UserModel?>((ref) async {
  final userId = await ref.read(authServiceProvider).getActiveUserId();
  if (userId == null) return null;
  return ref.read(isarServiceProvider).getUserById(userId);
});

final medicineListProvider =
    StateNotifierProvider<MedicineListNotifier, List<MedicineModel>>((ref) {
  final userId = ref.watch(userProvider).asData?.value?.id;
  return MedicineListNotifier(
    ref.read(isarServiceProvider),
    ref.read(notificationServiceProvider),
    userId,
  );
});

class MedicineListNotifier extends StateNotifier<List<MedicineModel>> {
  final IsarService _isar;
  final NotificationService _notifications;
  final int? _userId;

  MedicineListNotifier(this._isar, this._notifications, this._userId)
      : super([]) {
    if (_userId != null) _loadMedicines();
  }

  Future<void> _loadMedicines() async {
    state = await _isar.getAllMedicines(_userId!);
  }

  Future<void> addMedicine(MedicineModel medicine) async {
    if (_userId == null) return;
    medicine.userId = _userId;
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
