import 'dart:convert';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walletbillow/despesa/obj_despesa.dart';

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

  //Last torne-se pro, retorna a ultima vez que foi questionado em se tornar pró.
  static DateTime get lastRequestPro {
    return DateTime.fromMillisecondsSinceEpoch(Config.prefs!.getInt("lastRequestPro") ?? 0);
  }

  static set lastRequestPro(DateTime value) {
    Config.prefs!.setInt("lastRequestPro", value.millisecondsSinceEpoch);
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
  static List<Despesa> get gastos {
    String gastosStr = Config.prefs!.getString("gastos") ?? "[]";

    List gastos_ = jsonDecode(gastosStr);
    List<Despesa> gastos = [];

    for (Map gasto in gastos_) {
      gastos.add(Despesa.fromMap(gasto));
    }

    return gastos;
  }

  static set gastos(List<Despesa> value) {
    List<Map> despesasMap = List.generate(value.length, (index) => value[index].toMap);
    Config.prefs!.setString("gastos", jsonEncode(despesasMap));
  }

  static void addGasto(Despesa despesa) {
    List<Despesa> gastos = Config.gastos;
    gastos.add(despesa);
    Config.gastos = gastos;
  }

  static void removeGasto(String id, int parcela) {
    List<Despesa> gastos = Config.gastos.where((element) => !(element.id == id && element.parcelaAtual == parcela)).toList();
    Config.gastos = gastos;
  }

  static void editGasto(
    String id,
    int parcela, {
    bool? pago,
    String? nome,
    DateTime? data,
    double? valor,
    bool? fixo,
    int? parcelasTotal,
  }) {
    List<Despesa> gastos = Config.gastos.map((element) {
      if (element.id == id && element.parcelaAtual == parcela) {
        element.pago = pago ?? element.pago;
        element.nome = nome ?? element.nome;
        element.data = data ?? element.data;
        element.valor = valor ?? element.valor;
        element.fixo = fixo ?? element.fixo;
        element.parcelasTotal = parcelasTotal ?? element.parcelasTotal;
      }

      return element;
    }).toList();

    Config.gastos = gastos;
  }

  static void addListGastos(List<Despesa> despesas) {
    List<Despesa> gastos = Config.gastos;
    gastos.addAll(despesas);
    Config.gastos = gastos;
  }

  static void removeListGastos(List<String> ids, List<int> parcelas) {
    if (ids.length != parcelas.length) {
      throw Exception("As listas de ids e de parcelas devem ter o mesmo tamanho");
    }

    List<Despesa> gastos = Config.gastos.where((element) {
      for (int index = 0; index < ids.length; index++) {
        if (element.id == ids[index] && element.parcelaAtual == parcelas[index]) {
          return false;
        }
      }
      return true;
    }).toList();

    Config.gastos = gastos;
  }

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
