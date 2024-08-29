import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walletbillow/core/models/lancamentos/lancamento.dart';

class Gastos {
  static Future<Gastos> init() async {
    await Future.delayed(const Duration(seconds: 3));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return Gastos(prefs);
  }

  SharedPreferences prefs;
  Gastos(this.prefs);

  List<Lancamento> get gastos {
    String gastosStr = prefs.getString("gastos") ?? "[]";

    List gastos_ = jsonDecode(gastosStr);
    List<Lancamento> gastos = [];

    for (Map gasto in gastos_) {
      gastos.add(Lancamento.fromMap(gasto));
    }

    return gastos;
  }

  set gastos(List<Lancamento> value) {
    List<Map> despesasMap = List.generate(value.length, (index) => value[index].toMap);
    prefs.setString("gastos", jsonEncode(despesasMap));
  }

  void addGasto(Lancamento despesa) {
    List<Lancamento> newGastos = gastos;
    newGastos.add(despesa);
    gastos = newGastos;
  }

  void removeGasto(String id, int parcela) {
    List<Lancamento> newGastos = gastos.where((element) => !(element.id == id && element.parcelaAtual == parcela)).toList();
    gastos = newGastos;
  }

  void editGasto(
    String id,
    int parcela, {
    bool? pago,
    String? nome,
    DateTime? data,
    double? valor,
    bool? fixo,
    int? parcelasTotal,
  }) {
    List<Lancamento> newGastos = gastos.map((element) {
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

    gastos = newGastos;
  }

  void addListGastos(List<Lancamento> despesas) {
    List<Lancamento> newGastos = gastos;
    newGastos.addAll(despesas);
    gastos = newGastos;
  }

  void removeListGastos(List<String> ids, List<int> parcelas) {
    if (ids.length != parcelas.length) {
      throw Exception("As listas de ids e de parcelas devem ter o mesmo tamanho");
    }

    List<Lancamento> newGastos = gastos.where((element) {
      for (int index = 0; index < ids.length; index++) {
        if (element.id == ids[index] && element.parcelaAtual == parcelas[index]) {
          return false;
        }
      }
      return true;
    }).toList();

    gastos = newGastos;
  }
}
