import 'dart:convert';
import 'package:walletbillow/configuracoes/config_data.dart';
import 'package:walletbillow/despesa/obj_despesa.dart';

class Gastos {
  List<Despesa> get gastos {
    String gastosStr = Config.prefs!.getString("gastos") ?? "[]";

    List gastos_ = jsonDecode(gastosStr);
    List<Despesa> gastos = [];

    for (Map gasto in gastos_) {
      gastos.add(Despesa.fromMap(gasto));
    }

    return gastos;
  }

  set gastos(List<Despesa> value) {
    List<Map> despesasMap = List.generate(value.length, (index) => value[index].toMap);
    Config.prefs!.setString("gastos", jsonEncode(despesasMap));
  }

  void addGasto(Despesa despesa) {
    List<Despesa> newGastos = gastos;
    newGastos.add(despesa);
    gastos = newGastos;
  }

  void removeGasto(String id, int parcela) {
    List<Despesa> newGastos = gastos.where((element) => !(element.id == id && element.parcelaAtual == parcela)).toList();
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
    List<Despesa> newGastos = gastos.map((element) {
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

  void addListGastos(List<Despesa> despesas) {
    List<Despesa> newGastos = gastos;
    newGastos.addAll(despesas);
    gastos = newGastos;
  }

  void removeListGastos(List<String> ids, List<int> parcelas) {
    if (ids.length != parcelas.length) {
      throw Exception("As listas de ids e de parcelas devem ter o mesmo tamanho");
    }

    List<Despesa> newGastos = gastos.where((element) {
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
