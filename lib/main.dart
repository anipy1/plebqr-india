import 'package:flutter/material.dart';
import 'package:plebqr_india/component_library/component_library.dart';
import 'package:plebqr_india/key_value_storage/key_value_storage.dart';
import 'package:plebqr_india/plebqr_api/plebqr_api.dart';
import 'package:plebqr_india/plebqr_repository/plebqr_repository.dart';
import 'package:plebqr_india/routing_table.dart';
import 'package:routemaster/routemaster.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  final keyValueStorage = KeyValueStorage();

  // Initialize API and Repository
  final plebQrApi = PlebQrApi();
  final plebQrRepository = PlebQrRepository(
    keyValueStorage: keyValueStorage,
    remoteApi: plebQrApi,
  );

  runApp(PlebQrIndia(plebQrRepository: plebQrRepository));
}

class PlebQrIndia extends StatefulWidget {
  const PlebQrIndia({required this.plebQrRepository, super.key});

  final PlebQrRepository plebQrRepository;

  @override
  State<PlebQrIndia> createState() => _PlebQrIndiaState();
}

class _PlebQrIndiaState extends State<PlebQrIndia> {
  late final RoutemasterDelegate _routerDelegate;
  final _lightTheme = LightPlebQrThemeData();
  final _darkTheme = DarkPlebQrThemeData();

  @override
  void initState() {
    super.initState();
    _routerDelegate = RoutemasterDelegate(
      routesBuilder: (context) {
        return RouteMap(
          routes: buildRoutingTable(
            routerDelegate: _routerDelegate,
            plebQrRepository: widget.plebQrRepository,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlebQrTheme(
      lightTheme: _lightTheme,
      darkTheme: _darkTheme,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'PlebQR India',
        theme: _lightTheme.materialThemeData,
        darkTheme: _darkTheme.materialThemeData,
        themeMode: ThemeMode.system,
        routerDelegate: _routerDelegate,
        routeInformationParser: const RoutemasterParser(),
      ),
    );
  }
}
