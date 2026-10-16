import 'model/commission_model.dart';

abstract class ICommissionRepository {
  Future<List<CommissionModel>> getCommissions({
    required String clientId,
    required String startDate,
    required String endDate,
  });
}
