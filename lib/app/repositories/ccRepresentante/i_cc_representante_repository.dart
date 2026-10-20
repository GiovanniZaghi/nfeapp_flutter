import 'model/cc_representante_model.dart';

abstract class ICCRepresentanteRepository {
  Future<List<CCRepresentanteModel>> getExtrato();
}
