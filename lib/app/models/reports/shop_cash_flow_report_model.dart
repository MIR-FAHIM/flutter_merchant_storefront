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
  final CashFormula? cashFormula;

  ShopCashFlowReportData({
    this.from,
    this.to,
    this.period,
    this.kpiCards,
    this.ledgerRows = const [],
    this.totals,
    this.cashFormula,
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
      cashFormula: json['cash_formula'] is Map
          ? CashFormula.fromJson(Map<String, dynamic>.from(json['cash_formula']))
          : null,
    );
  }
}

class KpiCards {
  final double expectedCashInDrawer;
  final double totalDigitalPayments;
  final double todayNewBaki;
  final double totalStoreOutstandingBaki;
  final double? actualClosingCash;
  final double? drawerDifference;
  final double? carryForwardCash;

  KpiCards({
    this.expectedCashInDrawer = 0.0,
    this.totalDigitalPayments = 0.0,
    this.todayNewBaki = 0.0,
    this.totalStoreOutstandingBaki = 0.0,
    this.actualClosingCash,
    this.drawerDifference,
    this.carryForwardCash,
  });

  factory KpiCards.fromJson(Map<String, dynamic> json) {
    return KpiCards(
      expectedCashInDrawer: _parseDouble(json['expected_cash_in_drawer']),
      totalDigitalPayments: _parseDouble(json['total_digital_payments']),
      todayNewBaki: _parseDouble(json['today_new_baki']),
      totalStoreOutstandingBaki: _parseDouble(json['total_store_outstanding_baki']),
      actualClosingCash: _parseNullableDouble(json['actual_closing_cash']),
      drawerDifference: _parseNullableDouble(json['drawer_difference']),
      carryForwardCash: _parseNullableDouble(json['carry_forward_cash']),
    );
  }
}

class CashFormula {
  final Map<String, dynamic> values;

  CashFormula.fromJson(Map<String, dynamic> json)
      : values = Map.unmodifiable(json);

  double? _amount(List<String> keys) {
    for (final key in keys) {
      final value = _parseNullableDouble(values[key]);
      if (value != null) return value;
    }
    return null;
  }

  double? get openingCash => _amount(['opening_cash', 'opening_balance']);
  double? get cashSales => _amount(['cash_sales', 'total_cash_sales']);
  double? get bakiCashCollection =>
      _amount(['baki_cash_collection', 'baki_cash_collections']);
  double? get ownerDeposit => _amount(['owner_deposit', 'owner_deposits']);
  double? get expense => _amount(['expense', 'expenses', 'cash_expenses']);
  double? get ownerWithdrawal =>
      _amount(['owner_withdrawal', 'owner_withdrawals']);
  double? get drawerAdjustment =>
      _amount(['drawer_adjustment', 'drawer_adjustments']);
}

class CashboxAmounts {
  final double openingCash;
  final double cashSales;
  final double bakiCashCollection;
  final double ownerDeposit;
  final double expense;
  final double refunds;
  final double ownerWithdrawal;
  final double drawerAdjustment;

  CashboxAmounts.fromReport(ShopCashFlowReportData? report)
      : openingCash = report?.cashFormula?.openingCash ??
            _sum(report, (row) => row.section == 'OPENING_BALANCE', false),
        cashSales = report?.cashFormula?.cashSales ??
            _sum(report, (row) => row.section == 'REVENUE_INFLOW' &&
                !_isDigital(row) && !_isOwnerDeposit(row) &&
                !_isBakiCollection(row), false),
        bakiCashCollection = report?.cashFormula?.bakiCashCollection ??
            _sum(report, (row) => row.section == 'REVENUE_INFLOW' &&
                !_isDigital(row) && _isBakiCollection(row), false),
        ownerDeposit = report?.cashFormula?.ownerDeposit ??
            _sum(report, _isOwnerDeposit, false),
        expense = report?.cashFormula?.expense ??
            _sum(report, (row) => row.section == 'CASH_OUTFLOW' &&
                !_isOwnerWithdrawal(row) && !_isRefund(row), true),
        refunds = _sum(report, (row) =>
            row.section == 'CASH_OUTFLOW' && _isRefund(row), true),
        ownerWithdrawal = report?.cashFormula?.ownerWithdrawal ??
            _sum(report, _isOwnerWithdrawal, true),
        drawerAdjustment = report?.cashFormula?.drawerAdjustment ??
            (report?.ledgerRows ?? <LedgerRowItem>[])
                .where((row) => row.section == 'DRAWER_ADJUSTMENT')
                .fold<double>(0, (total, row) => total + row.netImpact);

  static String _description(LedgerRowItem row) =>
      '${row.title} ${row.flowType}'.toLowerCase();

  static bool _isDigital(LedgerRowItem row) {
    final text = _description(row);
    return ['digital', 'non-cash', 'non cash', 'aamarpay', 'bkash', 'nagad']
        .any(text.contains);
  }

  static bool _isOwnerDeposit(LedgerRowItem row) {
    final text = _description(row);
    return row.section.toUpperCase().contains('OWNER') &&
            row.section.toUpperCase().contains('DEPOSIT') ||
        text.contains('owner') && text.contains('deposit');
  }

  static bool _isOwnerWithdrawal(LedgerRowItem row) {
    final text = _description(row);
    return row.section.toUpperCase().contains('OWNER') &&
            row.section.toUpperCase().contains('WITHDRAWAL') ||
        text.contains('owner') && text.contains('withdrawal');
  }

  static bool _isBakiCollection(LedgerRowItem row) {
    final text = _description(row);
    return text.contains('baki') || text.contains('debt recovery');
  }

  static bool _isRefund(LedgerRowItem row) =>
      _description(row).contains('refund');

  static double _sum(ShopCashFlowReportData? report,
      bool Function(LedgerRowItem) matches, bool debit) {
    return (report?.ledgerRows ?? <LedgerRowItem>[])
        .where(matches)
        .fold<double>(0, (total, row) =>
            total + (debit ? row.debit : row.credit));
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

double? _parseNullableDouble(dynamic value) {
  final number = value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '');
  return number != null && number.isFinite ? number : null;
}
