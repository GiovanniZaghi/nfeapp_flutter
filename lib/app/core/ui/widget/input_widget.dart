import 'package:flutter/material.dart';

Widget buildInput(
  String label, {
  bool obscureText = false,
  TextEditingController? controller,
}) {
  return Container(
    margin: EdgeInsets.only(top: 4),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.blue.shade100),
      boxShadow: [
        BoxShadow(
          color: Colors.blue.shade50,
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: label,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: InputBorder.none,
      ),
    ),
  );
}
