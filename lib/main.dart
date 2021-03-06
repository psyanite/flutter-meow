import 'package:crust/components/common/main_tab_navigator.dart';
import 'package:crust/components/screens/splash_screen.dart';
import 'package:crust/presentation/platform_adaptive.dart';
import 'package:crust/state/app/app_middleware.dart';
import 'package:crust/state/app/app_reducer.dart';
import 'package:crust/state/app/app_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:redux_logging/redux_logging.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:redux_persist_flutter/redux_persist_flutter.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final persistor = Persistor<AppState>(
    storage: FlutterStorage(key: 'crust'),
    serializer: JsonSerializer<AppState>(AppState.rehydrate),
  );

  var initialState;
  try {
    initialState = await persistor.load();
  } catch (e, stack) {
    print('[ERROR] $e, $stack');
    initialState = null;
  }

  List<Middleware<AppState>> createMiddleware() {
    return <Middleware<AppState>>[
      persistor.createMiddleware(),
      LoggingMiddleware.printer(),
      ...createAppMiddleware(),
    ];
  }

  final store = Store<AppState>(
    appReducer,
    initialState: initialState ?? AppState(),
    middleware: createMiddleware(),
  );
  runApp(Main(store: store));
}

class MainRoutes {
  static const String home = '/';
  static const String splash = '/splash';
}

class Main extends StatefulWidget {
  final Store store;

  const Main({Key key, this.store}) : super(key: key);

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          systemNavigationBarColor: Color(0xFFEEEEEE),
          systemNavigationBarDividerColor: null,
          systemNavigationBarIconBrightness: Brightness.dark,
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        )
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: widget.store,
      child: MaterialApp(
        title: 'Burntoast',
        debugShowCheckedModeBanner: false,
        color: Color(0xFFF2993E),
        theme: getTheme(context),
        initialRoute: MainRoutes.splash,
        routes: <String, WidgetBuilder>{
          MainRoutes.splash: (context) => SplashScreen(),
          MainRoutes.home: (context) => MainTabNavigator(),
        },
        builder: (context, child) {
          var currentTsf = MediaQuery.of(context).textScaleFactor;
          var newTsf = -0.25 * currentTsf + 1;
          return MediaQuery(
            child: child,
            data: MediaQuery.of(context).copyWith(textScaleFactor: newTsf),
          );
        },
        localizationsDelegates: [
          CustomLocalizationDelegate(),
        ],
      ),
    );
  }
}

class CustomLocalizationDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const CustomLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'en';

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      SynchronousFuture<MaterialLocalizations>(const CustomLocalization());

  @override
  bool shouldReload(CustomLocalizationDelegate old) => false;

  @override
  String toString() => 'CustomLocalization.delegate(en_US)';
}

class CustomLocalization extends DefaultMaterialLocalizations {
  const CustomLocalization();

  @override
  String get searchFieldLabel => 'Search restaurants, cuisines...';
}
