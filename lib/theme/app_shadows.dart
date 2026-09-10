import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> raised = [
    BoxShadow(color: Color(0xD9020304), blurRadius: 15, offset: Offset(7, 8)),
    BoxShadow(color: Color(0x77292D34), blurRadius: 8, offset: Offset(-3, -4)),
  ];

  static const List<BoxShadow> subtle = [
    BoxShadow(color: Color(0xB3020304), blurRadius: 12, offset: Offset(5, 6)),
    BoxShadow(color: Color(0x66292D34), blurRadius: 7, offset: Offset(-2, -3)),
  ];

  static const List<BoxShadow> rubberButton = [
    BoxShadow(color: Color(0xD9020304), blurRadius: 14, offset: Offset(6, 7)),
    BoxShadow(color: Color(0x77292D34), blurRadius: 7, offset: Offset(-2, -3)),
  ];

  static const List<BoxShadow> rubberButtonPressed = [
    BoxShadow(color: Color(0xB3020304), blurRadius: 4, offset: Offset(1, 2)),
  ];
}
