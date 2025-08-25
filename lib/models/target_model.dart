import 'package:flutter/material.dart';

class TargetModel {
  final String spritePath;
  final Color fallbackColor;
  final double size;

  const TargetModel({
    required this.spritePath,
    required this.fallbackColor,
    this.size = 80.0,
  });
}
