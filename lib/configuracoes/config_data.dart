import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walletbillow/gastos/gastos.dart';

class Config {
  static SharedPreferences? prefs;
  static BuildContext? context;

  //Iniciando as configurações
  static Future<bool> init(BuildContext context) async {
    Config.prefs = await SharedPreferences.getInstance();
    Config.context = context;
    return true;
  }

  //Dados do usuário ///////////////////////////////
  //Usuário pró
  static bool get isPro {
    return Config.prefs!.getBool("pro") ?? false;
  }

  static set isPro(bool value) {
    Config.prefs!.setBool("pro", false);
  }

  //Dia do pagamento para virada do mês
  static int get diaPagamento {
    return Config.prefs!.getInt("diaPagamento") ?? 5;
  }

  static set diaPagamento(int value) {
    Config.prefs!.setInt("diaPagamento", value);
  }

  //Alerta de gasto excedido
  static double get gastoMax {
    return Config.prefs!.getDouble("gastoMax") ?? 0.0;
  }

  static set gastoMax(double value) {
    Config.prefs!.setDouble("gastoMax", value);
  }

  // Verificação se o usuário já avaliou o app
  static bool get avaliouOApp {
    return Config.prefs!.getBool("avaliouOApp") ?? false;
  }

  static set avaliouOApp(bool val) {
    Config.prefs!.setBool("avaliouOApp", val);
  }

  static DateTime get lastAvaliarOApp {
    return DateTime.fromMillisecondsSinceEpoch(Config.prefs!.getInt("lastAvaliarOApp") ?? 0);
  }

  static set lastAvaliarOApp(DateTime value) {
    Config.prefs!.setInt("lastAvaliarOApp", value.millisecondsSinceEpoch);
  }

  //Gastos ////////////////////////////////////////////
  static Gastos gastos = Gastos();

  //Dados do APP ///////////////////
  //Thema
  static AdaptiveThemeMode get thema {
    String tipo = Config.prefs?.getString("thema") ?? "aparelho";
    return tipo == "aparelho" ? AdaptiveThemeMode.system : (tipo == "claro" ? AdaptiveThemeMode.light : AdaptiveThemeMode.dark);
  }

  static set thema(AdaptiveThemeMode value) {
    Config.prefs!.setString(
      "thema",
      value == AdaptiveThemeMode.system
          ? "aparelho"
          : value == AdaptiveThemeMode.light
              ? "claro"
              : "escuro",
    );
  }
}
