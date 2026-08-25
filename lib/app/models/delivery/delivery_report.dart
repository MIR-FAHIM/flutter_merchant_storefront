// To parse this JSON data, do
//
// final deliveryReportModel = deliveryReportModelFromJson(jsonString);

import 'dart:convert';

DeliveryReportModel deliveryReportModelFromJson(String str) =>
    DeliveryReportModel.fromJson(json.decode(str) as Map<String, dynamic>);

String deliveryReportModelToJson(DeliveryReportModel data) =>
    json.encode(data.toJson());

class DeliveryReportModel {
  final String? status;
  final String? message;
  final DeliveryReportData? data;

  const DeliveryReportModel({
    this.status,
    this.message,
    this.data,
  });

  factory DeliveryReportModel.fromJson(Map<String, dynamic> json) =>
      DeliveryReportModel(
        status: json["status"] as String?,
        message: json["message"] as String?,
        data: json["data"] == null
            ? null
            : DeliveryReportData.fromJson(
          json["data"] as Map<String, dynamic>,
        ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class DeliveryReportData {
  final int? completedOrderCount;
  final int? pendingOrderCount;
  final int? assignedOrderCount;
  final int? pickedOrderCount;
  final int? onTheWayOrderCount;
  final int? deliveredOrderCount;
  final int? canceledCount;
  final DeliveryAmount? amount;

  const DeliveryReportData({
    this.completedOrderCount,
    this.pendingOrderCount,
    this.assignedOrderCount,
    this.pickedOrderCount,
    this.onTheWayOrderCount,
    this.deliveredOrderCount,
    this.canceledCount,
    this.amount,
  });

  factory DeliveryReportData.fromJson(Map<String, dynamic> json) =>
      DeliveryReportData(
        completedOrderCount: _asInt(json["completed_order_count"]),
        pendingOrderCount: _asInt(json["pending_order_count"]),
        assignedOrderCount: _asInt(json["assigned_order_count"]),
        pickedOrderCount: _asInt(json["picked_order_count"]),
        onTheWayOrderCount: _asInt(json["on_the_way_order_count"]),
        deliveredOrderCount: _asInt(json["delivered_order_count"]),
        canceledCount: _asInt(json["cenceled_count"]),
        amount: json["amount"] == null
            ? null
            : DeliveryAmount.fromJson(
          json["amount"] as Map<String, dynamic>,
        ),
      );

  Map<String, dynamic> toJson() => {
    "completed_order_count": completedOrderCount,
    "pending_order_count": pendingOrderCount,
    "assigned_order_count": assignedOrderCount,
    "picked_order_count": pickedOrderCount,
    "on_the_way_order_count": onTheWayOrderCount,
    "delivered_order_count": deliveredOrderCount,
    "cenceled_count": canceledCount,
    "amount": amount?.toJson(),
  };
}

class DeliveryAmount {
  final int? collectedAmount;
  final int? earnings;

  const DeliveryAmount({
    this.collectedAmount,
    this.earnings,
  });

  factory DeliveryAmount.fromJson(Map<String, dynamic> json) =>
      DeliveryAmount(
        collectedAmount: _asInt(json["collected_amount"]),
        earnings: _asInt(json["earnings"]),
      );

  Map<String, dynamic> toJson() => {
    "collected_amount": collectedAmount,
    "earnings": earnings,
  };
}

/// Helpers

int? _asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}
