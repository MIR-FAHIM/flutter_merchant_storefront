import 'package:flutter/material.dart';

class SellerTip {
  const SellerTip({
    required this.id,
    required this.title,
    required this.summary,
    required this.icon,
    required this.estimatedTime,
    required this.steps,
    this.actionLabel,
    this.actionRoute,
  });

  final String id;
  final String title;
  final String summary;
  final IconData icon;
  final String estimatedTime;
  final List<SellerTipStep> steps;
  final String? actionLabel;
  final String? actionRoute;
}

class SellerTipStep {
  const SellerTipStep({
    required this.title,
    required this.description,
    this.note,
  });

  final String title;
  final String description;
  final String? note;
}
