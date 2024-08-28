import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:walletbillow/configuracoes/config_data.dart';
import 'package:walletbillow/configuracoes/config_screen.dart';
import 'package:walletbillow/paleta/cores.dart';
import 'package:walletbillow/telas/home/home.dart';

String versaoDoApp = "0.1.0";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Config.init(context);
    Cores.init(context);

    return FutureBuilder(
      future: Config.init(context),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            title: 'WB',
          );
        }

        return AdaptiveTheme(
          light: Cores.themaLight,
          dark: Cores.themaDark,
          initial: Config.thema,
          builder: (light, dark) => MaterialApp(
            title: 'WB',
            debugShowCheckedModeBanner: false,
            theme: light,
            darkTheme: dark,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              MonthYearPickerLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale.fromSubtags(languageCode: 'pt', countryCode: 'BR'),
            ],
            initialRoute: "/",
            routes: {
              "/": (context) => const Home(),
              "/configuracoes": (context) => const ConfigScreen(),
            },
          ),
        );
      },
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  ThemeData? currentTheme;

  setLightMode() {
    currentTheme = Cores.themaLight;
    notifyListeners();
  }

  setDarkmode() {
    currentTheme = Cores.themaDark;
    notifyListeners();
  }
}
