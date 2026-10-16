class CommissionModel {
  final String data;
  final String totalPed;
  final String totalDev;
  final String totalComi;

  CommissionModel({
    required this.data,
    required this.totalPed,
    required this.totalDev,
    required this.totalComi,
  });

  factory CommissionModel.fromJson(Map<String, dynamic> json) {
    return CommissionModel(
      data: json['DATA']?.toString() ?? '',
      totalPed: json['TOTALPED']?.toString() ?? '0,00',
      totalDev: json['TOTALDEV']?.toString() ?? '0,00',
      totalComi: json['TOTALCOMI']?.toString() ?? '0,00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'DATA': data,
      'TOTALPED': totalPed,
      'TOTALDEV': totalDev,
      'TOTALCOMI': totalComi,
    };
  }
}
