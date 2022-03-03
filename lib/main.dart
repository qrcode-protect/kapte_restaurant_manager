import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libertyrestaurant/routing/delegate.dart';
import 'package:libertyrestaurant/routing/parser.dart';
import 'package:libertyrestaurant/routing/route_state.dart';
import 'package:libertyrestaurant/pages/main_sreen.dart';
import 'package:libertyrestaurant/theme.dart';
import 'package:url_strategy/url_strategy.dart';

const firebaseKapteConfig = FirebaseOptions(
  apiKey: "AIzaSyCQeCHAVsvIIgEvUuBvm3FA5wk1AabaQV4",
  authDomain: "instant-duality-318708.firebaseapp.com",
  projectId: "instant-duality-318708",
  storageBucket: "instant-duality-318708.appspot.com",
  messagingSenderId: "621781899211",
  appId: "1:621781899211:web:9a21bb6f46e44d68c5884e",
  measurementId: "G-6T9CXYW4CM",
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseKapteConfig);
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  setPathUrlStrategy();
  runApp(
    ProviderScope(
      child: MyApp(
        savedThemeMode: savedThemeMode,
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key, required this.savedThemeMode}) : super(key: key);
  final AdaptiveThemeMode? savedThemeMode;
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final RouteState _routeState;
  late final SimpleRouterDelegate _routerDelegate;
  late final TemplateRouteParser _routeParser;
  final _navigatorKey = GlobalKey<NavigatorState>();
  @override
  void initState() {
    super.initState();

    _routeParser = TemplateRouteParser(
      allowedPaths: [
        '/accueil',
        '/etablissement',
        '/menus',
        '/commandes',
        '/settings',
        '/paiements',
        '/comptes',
        '/documents'
      ],
      initialRoute: '/accueil',
    );

    _routeState = RouteState(_routeParser);

    _routerDelegate = SimpleRouterDelegate(
      routeState: _routeState,
      navigatorKey: _navigatorKey,
      builder: (context) => AppNavigatoreState(
        navigatorKey: _navigatorKey,
      ),
    );

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: themeLight,
      dark: themeDark,
      initial: widget.savedThemeMode ?? AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => RouteStateScope(
        notifier: _routeState,
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: theme,
          darkTheme: darkTheme,
          routeInformationParser: _routeParser,
          routerDelegate: _routerDelegate,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _routeState.dispose();
    _routerDelegate.dispose();
    super.dispose();
  }
}
