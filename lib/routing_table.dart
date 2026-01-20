import 'package:flutter/material.dart';
import 'package:plebqr_india/features/payment_flow/src/payment_flow_screen.dart';
import 'package:plebqr_india/features/transactions/transaction_screen.dart';
import 'package:plebqr_india/plebqr_repository/plebqr_repository.dart';
import 'package:plebqr_india/tab_container_screen.dart';
import 'package:routemaster/routemaster.dart';

Map<String, PageBuilder> buildRoutingTable({
  required RoutemasterDelegate routerDelegate,
  required PlebQrRepository plebQrRepository,
}) {
  return {
    _PathConstants.tabContainerPath:
        (_) => CupertinoTabPage(
          child: const TabContainerScreen(),
          paths: [_PathConstants.payPath, _PathConstants.transactionsPath],
        ),
    _PathConstants.payPath:
        (_) => MaterialPage(
          name: 'pay',
          child: PaymentFlowScreen(repository: plebQrRepository),
        ),
    _PathConstants.transactionsPath:
        (_) => MaterialPage(
          name: 'transactions',
          child: TransactionScreen(repository: plebQrRepository),
        ),
  };
}

class _PathConstants {
  const _PathConstants._();

  static String get tabContainerPath => '/';

  static String get payPath => '${tabContainerPath}pay';

  static String get transactionsPath => '${tabContainerPath}transactions';
}
