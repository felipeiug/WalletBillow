import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:walletbillow/configuracoes/config_data.dart';
import 'package:walletbillow/despesa/obj_despesa.dart';

class HomeConfig {
  HomeConfig();

  DateTime _data = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  List<Despesa> despesas = [];

  // Lista de pagamentos
  Future getPayments() async {
    List<Despesa> gastos = Config.gastos.gastos;
    List<Despesa> newGastos = [];

    for (Despesa gasto in gastos) {
      if (gasto.inDateTimeRange(dateTimeRange)) {
        newGastos.add(gasto);
      }
    }

    newGastos.sort((a, b) => (a.data).compareTo(b.data));

    despesas = newGastos;
  }

  // Obter, setar, avançar ou voltar a data
  DateTime get data {
    return _data;
  }

  Future setData(DateTime data) async {
    _data = data;
    await getPayments();
  }

  // Avançar um mês
  Future nextMonth() async {
    _data = DateTime(_data.year, _data.month + 1, _data.day);
    await getPayments();
  }

  // Voltar um mês
  Future lastMonth() async {
    _data = DateTime(_data.year, _data.month - 1, _data.day);
    await getPayments();
  }

  // Receita e despesa total
  double get receitaDespesa {
    return receitaTotal + gastoTotal;
  }

  double get receitaTotal {
    double val = 0;
    for (Despesa despesa in receitas) {
      val += despesa.valor;
    }
    return val;
  }

  double get gastoTotal {
    double val = 0;
    for (Despesa despesa in gastos) {
      val += despesa.valor;
    }
    return val;
  }

  //Obter os gastos e receitas
  List<Despesa> get gastos {
    List<Despesa> despesasNow = [];

    for (Despesa despesa in despesas) {
      if (despesa.valor >= 0) {
        continue;
      }
      despesasNow.add(despesa);
    }

    despesasNow.sort((a, b) => a.data.compareTo(b.data));

    return despesasNow;
  }

  List<Despesa> get receitas {
    List<Despesa> despesasNow = [];

    for (Despesa despesa in despesas) {
      if (despesa.valor < 0) {
        continue;
      }
      despesasNow.add(despesa);
    }

    despesasNow.sort((a, b) => a.data.compareTo(b.data));

    return despesasNow;
  }

  //Obter o intervalo das datas
  DateTimeRange get dateTimeRange {
    //Obtendo o intervalo das datas
    DateTime dataInicial;
    DateTime dataFinal;

    //Data inicial
    if (Config.diaPagamento > _data.day) {
      dataInicial = DateTime(_data.year, _data.month - 1, Config.diaPagamento);
      dataFinal = DateTime(_data.year, _data.month, Config.diaPagamento - 1);
    } else {
      dataInicial = DateTime(_data.year, _data.month, Config.diaPagamento);
      dataFinal = DateTime(_data.year, _data.month + 1, Config.diaPagamento - 1);
    }

    return DateTimeRange(start: dataInicial, end: dataFinal);
  }

  // Adicionar uma despesa
  Future addDespesa({
    required String nome,
    required DateTime data,
    required double valor,
    int parcelasTotal = 0,
    bool fixo = false,
  }) async {
    if (parcelasTotal == 0 && !fixo) {
      Despesa despesa = Despesa(
        nome: nome,
        data: data,
        valor: valor,
      );

      Config.gastos.addGasto(despesa);
    } else if (parcelasTotal != 0 || fixo) {
      String id = Despesa(nome: "", data: DateTime.now(), valor: 0).id;

      int qtdParcelas = parcelasTotal;
      if (qtdParcelas == 0) {
        qtdParcelas = 1200;
      }

      List<Despesa> despesas = List.generate(
        qtdParcelas,
        (parcela) {
          int dia = min(data.day, DateTime(data.year, data.month + parcela + 1, 0).day);
          DateTime dataNow = DateTime(data.year, data.month + parcela, dia);
          return Despesa(
            id: id,
            nome: nome,
            data: dataNow,
            valor: valor,
            parcelasTotal: parcelasTotal != 0 ? parcelasTotal : 0,
            parcelaAtual: parcela + 1,
            fixo: parcelasTotal == 0,
          );
        },
      );
      Config.gastos.addListGastos(despesas);
    }
    await getPayments();
  }

  // Adicionar uma despesa
  Future removeDespesa({
    required String id,
    required int parcela,
    bool removeAll = false,
  }) async {
    if (!removeAll) {
      Config.gastos.removeGasto(id, parcela);
    } else {
      List<Despesa> despesasRemover = Config.gastos.gastos.where((e) => (e.id == id && e.parcelaAtual >= parcela)).toList();
      Config.gastos.removeListGastos(
        despesasRemover.map((e) => e.id).toList(),
        despesasRemover.map((e) => e.parcelaAtual).toList(),
      );
    }

    await getPayments();
  }

  // Adicionar uma despesa
  Future editDespesa({
    required String id,
    required int parcela,
    required bool pago,
    required String descricao,
    required DateTime data,
    required double valor,
    required int parcelasTotal,
    required bool fixo,
    bool editAll = true,
  }) async {
    if (!editAll) {
      Config.gastos.editGasto(id, parcela, pago: pago, nome: descricao, data: data, valor: valor, fixo: fixo);
    } else {
      //Obtendo as despesas no intervalo
      List<Despesa> despesasMudar = Config.gastos.gastos.where((e) => (e.id == id)).toList();
      if (despesasMudar.isEmpty) {
        return;
      }
      despesasMudar.sort((a, b) => a.parcelaAtual.compareTo(b.parcelaAtual));

      // Removendo as despesas no intervalo para aplicar as modifcações
      Config.gastos.removeListGastos(
        despesasMudar.map((e) => e.id).toList(),
        despesasMudar.map((e) => e.parcelaAtual).toList(),
      );

      if (fixo == true) {
        parcelasTotal = 1200;
      }

      List<Despesa> despesasMudarTemp = [];
      DateTime dataInicial = despesasMudar.first.data;
      int subtrairParcela = 0;

      // Caso o primeiro seja fixo
      if (!fixo && despesasMudar.first.fixo) {
        String newId = Despesa(nome: "", data: dataInicial, valor: 0).id;

        for (int parcelaAtual = 1; parcelaAtual < parcela; parcelaAtual++) {
          //Data Antiga
          int dia = min(dataInicial.day, DateTime(dataInicial.year, dataInicial.month + parcelaAtual, 0).day);
          DateTime dataAntiga = DateTime(dataInicial.year, dataInicial.month + parcelaAtual - 1, dia);

          // Adicionando a despesa antiga com o novo id
          if (despesasMudar.isNotEmpty && despesasMudar.first.data.compareTo(dataAntiga) == 0) {
            despesasMudarTemp.add(Despesa(
              id: newId,
              nome: despesasMudar.first.nome,
              data: despesasMudar.first.data,
              valor: despesasMudar.first.valor,
              pago: despesasMudar.first.pago,
              parcelasTotal: despesasMudar.first.parcelasTotal,
              parcelaAtual: despesasMudar.first.parcelaAtual,
              fixo: despesasMudar.first.fixo,
            ));
            despesasMudar.removeAt(0);
          }
          subtrairParcela += 1;
        }
        //Atualizo a data inicial para a nova data
        if (despesasMudar.isNotEmpty) {
          dataInicial = despesasMudar.first.data;
        }
      }

      for (int parcelaAtual = 1; parcelaAtual < parcelasTotal + 1; parcelaAtual++) {
        //Data Antiga
        int dia = min(dataInicial.day, DateTime(dataInicial.year, dataInicial.month + parcelaAtual, 0).day);
        DateTime dataAntiga = DateTime(dataInicial.year, dataInicial.month + parcelaAtual - 1, dia);

        // Data nova
        dia = min(data.day, DateTime(dataInicial.year, dataInicial.month + parcelaAtual, 0).day);
        DateTime dataNova = DateTime(dataInicial.year, dataInicial.month + parcelaAtual - 1, dia);

        Despesa? despesaAdd;
        if (despesasMudar.isNotEmpty && despesasMudar.first.data.compareTo(dataAntiga) == 0) {
          // Caso esteja nas parcelas para atualizar
          if (parcelaAtual >= (parcela - subtrairParcela)) {
            despesasMudar.first.data = dataNova;
            despesasMudar.first.fixo = fixo;
            despesasMudar.first.nome = descricao;
            despesasMudar.first.pago = pago;
            despesasMudar.first.parcelaAtual = parcelaAtual;
            despesasMudar.first.valor = valor;
          } else {
            despesasMudar.first.parcelaAtual -= subtrairParcela;
          }
          despesasMudar.first.parcelasTotal = fixo ? 0 : parcelasTotal;
          despesaAdd = Despesa(
            id: id,
            nome: despesasMudar.first.nome,
            data: despesasMudar.first.data,
            valor: despesasMudar.first.valor,
            pago: despesasMudar.first.pago,
            parcelasTotal: despesasMudar.first.parcelasTotal,
            parcelaAtual: despesasMudar.first.parcelaAtual,
            fixo: despesasMudar.first.fixo,
          );

          despesasMudar.removeAt(0);
        } else if (despesasMudar.isEmpty) {
          despesaAdd = Despesa(
            id: id,
            nome: descricao,
            data: dataNova,
            valor: valor,
            pago: pago,
            parcelasTotal: fixo ? 0 : parcelasTotal,
            parcelaAtual: parcelaAtual,
            fixo: fixo,
          );
        }
        if (despesaAdd != null) {
          despesasMudarTemp.add(despesaAdd);
        }
      }

      Config.gastos.addListGastos(despesasMudarTemp);
    }
    await getPayments();
  }

  //////////////// Dados para o gráfico

  // Spots para o gráfico
  List<List<FlSpot>> get receitaDespesaSpot {
    List<List<FlSpot>> spots = [
      [], //Receitas
      [], //Gastos
      [], //Diferença
    ];
    DateTimeRange intervaloDatas = dateTimeRange;
    int dia = 0;

    double valReceita = 0;
    double valGasto = 0;
    while (true) {
      DateTime dataAtual = DateTime(intervaloDatas.start.year, intervaloDatas.start.month, intervaloDatas.start.day + dia);
      dia += 1;

      if (dataAtual.compareTo(intervaloDatas.end) == 1) {
        break;
      }

      for (Despesa despesa in despesas) {
        if (despesa.data.compareTo(dataAtual) == 0) {
          if (despesa.valor < 0) {
            valGasto += despesa.valor;
          } else {
            valReceita += despesa.valor;
          }
        }
      }

      double dataUs = dataAtual.microsecondsSinceEpoch.toDouble();

      spots[0].add(FlSpot(dataUs, valReceita));
      spots[1].add(FlSpot(dataUs, valGasto));
      spots[2].add(FlSpot(dataUs, valReceita + valGasto));
    }
    return spots;
  }
}

class GraficConfig {
  GraficConfig({
    required this.dataInicial,
    required this.dataFinal,
    required this.intervalos,
  });

  DateTime dataInicial;
  DateTime dataFinal;
  DateRange intervalos;
}

enum DateRange {
  dias,
  meses,
  anos,
}
