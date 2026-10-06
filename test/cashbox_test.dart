import 'dart:convert';
import 'dart:io';

import 'package:ecom_delivery_flutter/app/api_providers/api_url.dart';
import 'package:ecom_delivery_flutter/app/models/reports/shop_cash_flow_report_model.dart';
import 'package:ecom_delivery_flutter/app/modules/reports/controllers/shop_cash_flow_controller.dart';
import 'package:ecom_delivery_flutter/app/modules/reports/views/seller_cash_flow_guide_screen.dart';
import 'package:ecom_delivery_flutter/app/modules/reports/views/widgets/cashbox_entry_bottom_sheet.dart';
import 'package:ecom_delivery_flutter/app/modules/reports/views/widgets/set_opening_cash_bottom_sheet.dart';
import 'package:ecom_delivery_flutter/app/modules/reports/views/widgets/shop_cash_flow_report_widget.dart';
import 'package:ecom_delivery_flutter/app/repositories/shop_cash_flow_repository.dart';
import 'package:ecom_delivery_flutter/common/payment_method_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _CashRepository extends ShopCashFlowRepository {
  final List<Map<String, dynamic>> withdrawals = [];
  final List<Map<String, dynamic>> deposits = [];
  final List<Map<String, dynamic>> closings = [];
  final List<Map<String, dynamic>> carries = [];
  final List<Map<String, dynamic>> reports = [];
  double expectedCash = 10000;
  bool failClosing = false;

  Map<String, dynamic> _success() => {
        'status_code': 201,
        'body': {'status': 'success', 'message': 'Saved'},
      };

  @override
  Future<Map<String, dynamic>> fetchSummaryReport({
    required String storeId,
    String? period,
    String? from,
    String? to,
  }) async {
    reports.add({'storeId': storeId, 'period': period, 'from': from, 'to': to});
    return {
      'status_code': 200,
      'body': {
        'status': 'success',
        'data': {
          'kpi_cards': {'expected_cash_in_drawer': expectedCash},
        },
      }
    };
  }

  @override
  Future<Map<String, dynamic>> recordOwnerWithdrawal({
    required String storeId,
    required Map<String, dynamic> body,
  }) async {
    withdrawals.add(body);
    expectedCash -= body['amount'] as double;
    return _success();
  }

  @override
  Future<Map<String, dynamic>> recordOwnerDeposit({
    required String storeId,
    required Map<String, dynamic> body,
  }) async {
    deposits.add(body);
    return _success();
  }

  @override
  Future<Map<String, dynamic>> recordClosingCash({
    required String storeId,
    required Map<String, dynamic> body,
  }) async {
    closings.add(body);
    return failClosing
        ? {
            'status_code': 422,
            'body': {
              'message': 'Validation failed',
              'errors': {
                'actual_cash': ['Try again']
              },
            }
          }
        : _success();
  }

  @override
  Future<Map<String, dynamic>> recordCarryForward({
    required String storeId,
    required Map<String, dynamic> body,
  }) async {
    carries.add(body);
    return _success();
  }
}

class _CashController extends ShopCashFlowController {
  _CashController(_CashRepository repository) : super(repository: repository);
  final storeId = '68'.obs;
  @override
  String get currentStoreId => storeId.value;
}

LedgerRowItem _row(String section, String title,
        {double credit = 0, double debit = 0}) =>
    LedgerRowItem(
        section: section,
        title: title,
        flowType: '',
        credit: credit,
        debit: debit);

Map<String, String> _localeStrings(String locale) {
  final json =
      jsonDecode(File('assets/locales/$locale.json').readAsStringSync())
          as Map<String, dynamic>;
  final translations = <String, String>{};
  void flatten(Map map, [String prefix = '']) {
    for (final entry in map.entries) {
      final key = prefix.isEmpty ? '${entry.key}' : '$prefix.${entry.key}';
      if (entry.value is Map) {
        flatten(entry.value as Map, key);
      } else {
        translations[key] = entry.value.toString();
      }
    }
  }

  flatten(json);
  return translations;
}

void main() {
  tearDown(() {
    Get.reset();
    Get.clearTranslations();
  });

  test('seller-store report and owner endpoints use the expected routes', () {
    expect(ApiClient.shopFinancialSummary('68', period: 'today'),
        endsWith('/api/seller/stores/68/reports/summary?period=today'));
    expect(
        ApiClient.cashLogWithdrawal('68'), endsWith('/cash-logs/withdrawal'));
    expect(ApiClient.cashLogDeposit('68'), endsWith('/cash-logs/deposit'));
    expect(ApiClient.cashLogClosing('68'), endsWith('/cash-logs/closing'));
    expect(ApiClient.cashLogCarryForward('68'),
        endsWith('/cash-logs/carry-forward'));
  });

  test('cash formula takes priority and zero closing is distinct from missing',
      () {
    final report = ShopCashFlowReportData.fromJson({
      'kpi_cards': {
        'actual_closing_cash': 0,
        'drawer_difference': '0.00',
        'carry_forward_cash': 0
      },
      'cash_formula': {
        'opening_cash': '500',
        'cash_sales': 1000,
        'baki_cash_collection': 50,
        'owner_deposit': 200,
        'expense': 30,
        'owner_withdrawal': 100
      },
    });
    final amounts = CashboxAmounts.fromReport(report);
    expect(amounts.openingCash, 500);
    expect(amounts.cashSales, 1000);
    expect(amounts.bakiCashCollection, 50);
    expect(amounts.ownerDeposit, 200);
    expect(amounts.expense, 30);
    expect(amounts.ownerWithdrawal, 100);
    expect(report.kpiCards!.actualClosingCash, 0);
    expect(KpiCards.fromJson({}).actualClosingCash, isNull);
  });

  test('ledger fallback excludes digital and separates owner movements', () {
    final amounts =
        CashboxAmounts.fromReport(ShopCashFlowReportData(ledgerRows: [
      _row('OPENING_BALANCE', 'Opening Cash', credit: 500),
      _row('REVENUE_INFLOW', 'POS In-Store Cash Sales', credit: 1000),
      _row('REVENUE_INFLOW', 'Baki Recovered', credit: 50),
      _row('REVENUE_INFLOW', 'Online Payment / AamarPay', credit: 2000),
      _row('REVENUE_INFLOW', 'Owner Cash Deposit', credit: 200),
      _row('CASH_OUTFLOW', 'Shop Daily Expenses', debit: 30),
      _row('CASH_OUTFLOW', 'Owner Withdrawal', debit: 100),
      _row('CASH_OUTFLOW', 'Customer Cash Refunds', debit: 10),
      _row('CARRY_FORWARD', 'Cash kept for next day', credit: 300),
    ]));
    expect(amounts.cashSales, 1000);
    expect(amounts.bakiCashCollection, 50);
    expect(amounts.ownerDeposit, 200);
    expect(amounts.expense, 30);
    expect(amounts.ownerWithdrawal, 100);
    expect(amounts.refunds, 10);
  });

  testWidgets('validation blocks invalid amounts and preserves exact payloads',
      (tester) async {
    final repository = _CashRepository();
    final controller = _CashController(repository);
    await tester.pumpWidget(GetMaterialApp(home: const Scaffold()));
    final day = DateTime(2026, 10, 6);
    expect(
        await controller.submitOwnerWithdrawal(
            storeId: '68', amount: 0, date: day),
        false);
    expect(
        await controller.submitOwnerDeposit(
            storeId: '68', amount: -1, date: day),
        false);
    expect(
        await controller.submitClosingCash(
            storeId: '68',
            actualCash: -1,
            carryForwardAmount: 0,
            date: day,
            setNextOpening: false),
        false);
    expect(
        await controller.submitCarryForward(
            storeId: '68',
            amount: -1,
            fromDate: day,
            toDate: DateTime(2026, 10, 7)),
        false);
    expect(repository.withdrawals, isEmpty);
    expect(repository.deposits, isEmpty);
    expect(repository.closings, isEmpty);
    expect(repository.carries, isEmpty);
    expect(
        await controller.submitClosingCash(
            storeId: '68',
            actualCash: 5,
            carryForwardAmount: 10,
            date: day,
            setNextOpening: true),
        false);
    expect(
        await controller.submitCarryForward(
            storeId: '68', amount: 0, fromDate: day, toDate: day),
        false);
    expect(
        await controller.submitOwnerDeposit(
            storeId: '17', amount: 1, date: day),
        false);
    expect(
        await controller.submitOwnerDeposit(
            storeId: '68', amount: 5000, date: day),
        true);
    expect(repository.deposits.single,
        containsPair('category', 'Owner Cash Deposit'));
    expect(
        await controller.submitClosingCash(
            storeId: '68',
            actualCash: 0,
            carryForwardAmount: 0,
            date: day,
            setNextOpening: false),
        true);
    expect(repository.closings.single, {
      'actual_cash': 0.0,
      'entry_date': '2026-10-06',
      'carry_forward_amount': 0.0,
      'set_next_opening': false,
      'note': '',
    });
    await tester.pumpAndSettle();
    controller.onClose();
  });

  testWidgets('AamarPay displays as online payment, never cash',
      (tester) async {
    await tester.pumpWidget(GetMaterialApp(home: const Scaffold()));
    expect(paymentMethodLabel('cash'), 'paymentDisplay.cash');
    expect(paymentMethodLabel('aamarpay'), 'paymentDisplay.online');
    for (final method in ['bkash', 'nagad', 'card', 'bank']) {
      expect(paymentMethodLabel(method), 'paymentDisplay.digital');
    }
    expect(paymentMethodLabel('baki'), 'paymentDisplay.baki');
  });

  testWidgets(
      'Bangla day close accepts zero and retries without another withdrawal',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = _CashRepository()..failClosing = true;
    final controller = _CashController(repository);
    final json =
        jsonDecode(File('assets/locales/bn_BD.json').readAsStringSync())
            as Map<String, dynamic>;
    final translations = <String, String>{};
    for (final entry in (json['cashbox'] as Map).entries) {
      translations['cashbox.${entry.key}'] = entry.value.toString();
    }
    await tester.pumpWidget(GetMaterialApp(
      locale: const Locale('bn', 'BD'),
      translationsKeys: {'bn_BD': translations},
      home: Scaffold(
          body: CashboxEntryBottomSheet(
        controller: controller,
        storeId: '68',
        type: CashboxEntryType.closing,
      )),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '১০০০০');
    await tester.enterText(fields.at(1), '০');
    await tester.enterText(fields.at(2), '১০০০০');
    final withdraw = find.text(translations['cashbox.recordWithdrawal']!);
    await tester.ensureVisible(withdraw);
    await tester.tap(withdraw);
    await tester.pumpAndSettle();
    expect(repository.withdrawals.length, 1);
    expect(repository.withdrawals.single['category'], 'Owner Withdrawal');
    expect(
        repository.reports.any(
            (query) => query['from'] != null && query['from'] == query['to']),
        true);
    expect(
        (tester.widget<TextFormField>(fields.at(0))).controller!.text, '0.00');
    final closing = find.text(translations['cashbox.saveClosing']!);
    await tester.ensureVisible(closing);
    await tester.tap(closing);
    await tester.pumpAndSettle();
    expect(repository.closings.length, 1);
    expect(repository.closings.single['actual_cash'], 0);
    repository.failClosing = false;
    await tester.tap(closing);
    await tester.pumpAndSettle();
    expect(repository.withdrawals.length, 1);
    expect(repository.closings.length, 2);
    expect(tester.takeException(), isNull);
    controller.onClose();
  });

  testWidgets(
      'Bangla guide opens all four new cashbox entry forms on a small screen',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = _CashRepository();
    final controller = _CashController(repository);
    Get.put<ShopCashFlowController>(controller);
    await controller.fetchReport();
    controller.reportData.value = ShopCashFlowReportData.fromJson({
      'kpi_cards': {
        'expected_cash_in_drawer': 10000,
        'actual_closing_cash': 0,
        'drawer_difference': 0,
        'carry_forward_cash': 0
      },
      'cash_formula': {'owner_deposit': 5000, 'owner_withdrawal': 10000},
    });
    await tester.pumpWidget(GetMaterialApp(
      home: const SellerCashFlowGuideScreen(),
    ));
    await tester.pumpAndSettle();
    expect(find.text('মালিকের টাকা ও দিনশেষের হিসাব'), findsOneWidget);
    expect(find.text('মালিকের জমা: ৳5,000.00'), findsOneWidget);
    expect(tester.takeException(), isNull);
    for (final entry in {
      'cashbox.deposit': CashboxEntryType.deposit,
      'cashbox.withdrawal': CashboxEntryType.withdrawal,
      'cashbox.closing': CashboxEntryType.closing,
      'cashbox.carryForward': CashboxEntryType.carryForward,
    }.entries) {
      final button = find.text(entry.key.tr);
      expect(button, findsOneWidget);
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
      final sheet = find.byType(CashboxEntryBottomSheet);
      expect(tester.widget<CashboxEntryBottomSheet>(sheet).type, entry.value);
      expect(tester.takeException(), isNull);
      await tester.tap(find.descendant(
          of: sheet, matching: find.byIcon(Icons.close_rounded)));
      await tester.pumpAndSettle();
      expect(sheet, findsNothing);
    }
  });

  testWidgets(
      'report shows all eight actions and closing fields without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = _CashController(_CashRepository());
    Get.put<ShopCashFlowController>(controller);
    await controller.fetchReport();
    controller.reportData.value = ShopCashFlowReportData.fromJson({
      'kpi_cards': {
        'expected_cash_in_drawer': 10000,
        'actual_closing_cash': 0,
        'drawer_difference': 0,
        'carry_forward_cash': 0
      },
      'cash_formula': {
        'opening_cash': 5000,
        'cash_sales': 15000,
        'owner_deposit': 1000,
        'expense': 1000,
        'owner_withdrawal': 10000
      },
    });
    final json =
        jsonDecode(File('assets/locales/bn_BD.json').readAsStringSync())
            as Map<String, dynamic>;
    final translations = <String, String>{};
    void flatten(Map map, [String prefix = '']) {
      for (final entry in map.entries) {
        final key = prefix.isEmpty ? '${entry.key}' : '$prefix.${entry.key}';
        if (entry.value is Map) {
          flatten(entry.value as Map, key);
        } else {
          translations[key] = entry.value.toString();
        }
      }
    }

    flatten(json);
    await tester.pumpWidget(GetMaterialApp(
      locale: const Locale('bn', 'BD'),
      translationsKeys: {'bn_BD': translations},
      home: const Scaffold(
          body: SingleChildScrollView(
        child: ShopCashFlowReportWidget(),
      )),
    ));
    await tester.pumpAndSettle();
    for (final key in [
      'opening',
      'deposit',
      'withdrawal',
      'expense',
      'quickSale',
      'closing',
      'carryForward',
      'adjustment'
    ]) {
      expect(find.text(translations['cashbox.$key']!), findsWidgets);
    }
    expect(find.text(translations['cashbox.actualClosing']!), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final width in [320.0, 390.0, 800.0]) {
    testWidgets('invoice ledger fits $width px and keeps totals and actions',
        (tester) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final controller = _CashController(_CashRepository());
      Get.put<ShopCashFlowController>(controller);
      await controller.fetchReport();
      const longTitle = 'Additional audited movement with a long description '
          'that must remain readable in the invoice statement';
      controller.reportData.value = ShopCashFlowReportData(
        from: '2026-10-06T00:00:00+06:00',
        to: '2026-10-06T23:59:59+06:00',
        kpiCards: KpiCards(expectedCashInDrawer: 1200000.25),
        ledgerRows: [
          _row('OPENING_BALANCE', 'Opening Cash Drawer', credit: 5000),
          _row('REVENUE_INFLOW', 'POS In-Store Cash Sales', credit: 10000),
          _row('REVENUE_INFLOW', 'Digital Payments', credit: 2400),
          _row('CASH_OUTFLOW', 'Shop Daily Expenses', debit: 1000),
          _row('OWNER_DEPOSIT', 'Owner Cash Deposit', credit: 500),
          _row('OWNER_WITHDRAWAL', 'Owner Withdrawal', debit: 250),
          _row('DRAWER_ADJUSTMENT', 'Till Adjustment', debit: 25),
          _row('BAKI_FLOW', 'New Baki Given', credit: 3000),
          _row('CLOSING_BALANCE', 'Closing Cash Count'),
          _row('CARRY_FORWARD', 'Carry Forward', credit: 1000),
          _row('OTHER_AUDIT', longTitle, credit: 1200000.25),
        ],
      );
      controller.isLedgerTableExpanded.value = true;
      final language = width == 800 ? 'en_US' : 'bn_BD';
      await tester.pumpWidget(GetMaterialApp(
        locale:
            width == 800 ? const Locale('en', 'US') : const Locale('bn', 'BD'),
        translationsKeys: {language: _localeStrings(language)},
        home: const Scaffold(
            body: SingleChildScrollView(
          child: ShopCashFlowReportWidget(),
        )),
      ));
      await tester.pumpAndSettle();
      final invoice = find.byKey(const ValueKey('cash-ledger-invoice'));
      final decoration =
          tester.widget<Container>(invoice).decoration as BoxDecoration;
      expect(decoration.color, const Color(0xFF181A1D));
      expect(
          find.descendant(
              of: invoice, matching: find.text('cashLedger.expectedCash'.tr)),
          findsOneWidget);
      expect(find.descendant(of: invoice, matching: find.text('OTHER AUDIT')),
          findsOneWidget);
      expect(tester.widget<Text>(find.text(longTitle)).overflow,
          isNot(TextOverflow.ellipsis));
      expect(
          tester
              .widget<Text>(find.text('Digital Payments (bKash/Nagad)'.tr))
              .style!
              .color,
          const Color(0xFF93C5FD));
      expect(tester.takeException(), isNull);

      final toggle = find.byKey(const ValueKey('cash-ledger-toggle'));
      final expandedHeight = tester.getSize(invoice).height;
      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(controller.isLedgerTableExpanded.value, false);
      expect(tester.getSize(invoice).height, lessThan(expandedHeight));
      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(controller.isLedgerTableExpanded.value, true);
      final editOpening = find.byTooltip('Edit Till'.tr);
      await tester.ensureVisible(editOpening);
      await tester.tap(editOpening);
      await tester.pumpAndSettle();
      expect(find.byType(SetOpeningCashBottomSheet), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
