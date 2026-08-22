import 'package:flutter/material.dart';

class DayTimingModel {
  String name;
  bool isOpen;
  TimeOfDay? open;
  TimeOfDay? close;

  DayTimingModel({
    required this.name,
    this.isOpen = false,
    this.open,
    this.close,
  });
}