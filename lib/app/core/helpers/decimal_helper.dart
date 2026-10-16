double? parseDecimal(String? text) {
  if (text == null) return null;
  var value = text.trim().replaceAll(RegExp(r'\s'), '').replaceAll('R\$', '');
  if (value.isEmpty) return null;

  if (value.contains(',')) {
    value = value.replaceAll('.', '').replaceAll(',', '.');
  }
  return double.tryParse(value);
}

double round2(double value) => (value * 100).roundToDouble() / 100;

String formatDecimal(double value) =>
    round2(value).toStringAsFixed(2).replaceAll('.', ',');

String formatMoney(double value) {
  final fixed = round2(value).abs().toStringAsFixed(2);
  final parts = fixed.split('.');
  final grouped = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  final sign = value < 0 ? '-' : '';
  return '${sign}R\$ $grouped,${parts[1]}';
}
