class LoginModel {
  String? codigo;
  String? validado;
  String? empresa;
  String? frete;
  String? valKm;
  String? valMinKm;
  String? fantasia;
  String? email;
  String? imagem64;
  String? multitab;
  String? idRepr;

  LoginModel({
    this.codigo,
    this.validado,
    this.empresa,
    this.frete,
    this.valKm,
    this.valMinKm,
    this.fantasia,
    this.email,
    this.imagem64,
    this.multitab,
    this.idRepr,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      codigo: json['CODIGO'],
      validado: json['VALIDADO'],
      empresa: json['EMPRESA'],
      frete: json['FRETE'],
      valKm: json['VALKM'],
      valMinKm: json['VALMINKM'],
      fantasia: json['FANTASIA'],
      email: json['EMAIL'],
      imagem64: json['IMAGEM64'],
      multitab: json['MULTITAB']?.toString(),
      idRepr: json['ID_REPR']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'validado': validado,
      'empresa': empresa,
      'frete': frete,
      'valKm': valKm,
      'valMinKm': valMinKm,
      'fantasia': fantasia,
      'email': email,
      'imagem64': imagem64,
      'multitab': multitab,
      'idRepr': idRepr,
    };
  }
}
