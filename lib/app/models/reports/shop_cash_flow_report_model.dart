class ShopCashFlowReportResponse {
  final String? status;
  final String? message;
  final ShopCashFlowReportData? data;

  ShopCashFlowReportResponse({
    this.status,
    this.message,
    this.data,
  });

  factory ShopCashFlowReportResponse.fromJson(Map<String, dynamic> json) {
    return ShopCashFlowReportResponse(
      status: json['status']?.toString(),
      message: json['message']?.toString(),
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? ShopCashFlowReportData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ShopCashFlowReportData {
  final String? from;
  final String? to;
  final String? period;
  final KpiCards? kpiCards;
  final List<LedgerRowItem> ledgerRows;
  final LedgerTotals? totals;

  ShopCashFlowReportData({
    this.from,
    this.to,
    this.period,
    this.kpiCards,
    this.ledgerRows = const [],
    this.totals,
  });

  factory ShopCashFlowReportData.fromJson(Map<String, dynamic> json) {
    var rawRows = json['ledger_rows'];
    List<LedgerRowItem> rows = [];
    if (rawRows is List) {
      rows = rawRows
          .whereType<Map<String, dynamic>>()
          .map((e) => LedgerRowItem.fromJson(e))
          .toList();
    }

    return ShopCashFlowReportData(
      from: json['from']?.toString(),
      to: json['to']?.toString(),
      period: json['period']?.toString(),
      kpiCards: json['kpi_cards'] != null && json['kpi_cards'] is Map<String, dynamic>
          ? KpiCards.fromJson(json['kpi_cards'] as Map<String, dynamic>)
          : null,
      ledgerRows: rows,
      totals: json['totals'] != null && json['totals'] is Map<String, dynamic>
          ? LedgerTotals.fromJson(json['totals'] as Map<String, dynamic>)
          : null,
    );
  }
}

class KpiCards {
  final double expectedCashInDrawer;
  final double totalDigitalPayments;
  final double todayNewBaki;
  final double totalStoreOutstandingBaki;

  KpiCards({
    this.expectedCashInDrawer = 0.0,
    this.totalDigitalPayments = 0.0,
    this.todayNewBaki = 0.0,
    this.totalStoreOutstandingBaki = 0.0,
  });

  factory KpiCards.fromJson(Map<String, dynamic> json) {
    return KpiCards(
      expectedCashInDrawer: _parseDouble(json['expected_cash_in_drawer']),
      totalDigitalPayments: _parseDouble(json['total_digital_payments']),
      todayNewBaki: _parseDouble(json['today_new_baki']),
      totalStoreOutstandingBaki: _parseDouble(json['total_store_outstanding_baki']),
    );
  }
}

class LedgerRowItem {
  final String section;
  final String title;
  final String flowType;
  final double debit;
  final double credit;
  final double netImpact;

  LedgerRowItem({
    required this.section,
    required this.title,
    required this.flowType,
    this.debit = 0.0,
    this.credit = 0.0,
    this.netImpact = 0.0,
  });

  factory LedgerRowItem.fromJson(Map<String, dynamic> json) {
    return LedgerRowItem(
      section: json['section']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      flowType: json['flow_type']?.toString() ?? '',
      debit: _parseDouble(json['debit']),
      credit: _parseDouble(json['credit']),
      netImpact: _parseDouble(json['net_impact']),
    );
  }
}

class LedgerTotals {
  final double totalDebit;
  final double totalCredit;
  final double expectedCashDrawer;
  final double totalDigital;
  final double overallStoreBaki;

  LedgerTotals({
    this.totalDebit = 0.0,
    this.totalCredit = 0.0,
    this.expectedCashDrawer = 0.0,
    this.totalDigital = 0.0,
    this.overallStoreBaki = 0.0,
  });

  factory LedgerTotals.fromJson(Map<String, dynamic> json) {
    return LedgerTotals(
      totalDebit: _parseDouble(json['total_debit']),
      totalCredit: _parseDouble(json['total_credit']),
      expectedCashDrawer: _parseDouble(json['expected_cash_drawer']),
      totalDigital: _parseDouble(json['total_digital']),
      overallStoreBaki: _parseDouble(json['overall_store_baki']),
    );
  }
}

double _parseDouble(dynamic val) {
  if (val == null) return 0.0;
  if (val is num) return val.toDouble();
  if (val is String) {
    return double.tryParse(val) ?? 0.0;
  }
  return 0.0;
}
