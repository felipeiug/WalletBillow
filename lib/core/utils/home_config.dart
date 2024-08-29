import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:walletbillow/core/services/config_data.dart';
import 'package:walletbillow/core/models/lancamentos/lancamento.dart';
import 'package:walletbillow/core/services/gastos/gastos_db.dart';

class HomeUtil {
  Gastos gastosDB;
  HomeUtil(this.gastosDB);

  DateTime _data = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  List<Lancamento> despesas = [];

  // Lista de pagamentos
  Future getPayments() async {
    List<Lancamento> gastos = gastosDB.gastos;
    List<Lancamento> newGastos = [];

    for (Lancamento gasto in gastos) {
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
    for (Lancamento despesa in receitas) {
      val += despesa.valor;
    }
    return val;
  }

  double get gastoTotal {
    double val = 0;
    for (Lancamento despesa in gastos) {
      val += despesa.valor;
    }
    return val;
  }

  //Obter os gastos e receitas
  List<Lancamento> get gastos {
    List<Lancamento> despesasNow = [];

    for (Lancamento despesa in despesas) {
      if (despesa.valor >= 0) {
        continue;
      }
      despesasNow.add(despesa);
    }

    despesasNow.sort((a, b) => a.data.compareTo(b.data));

    return despesasNow;
  }

  List<Lancamento> get receitas {
    List<Lancamento> despesasNow = [];

    for (Lancamento despesa in despesas) {
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
      Lancamento despesa = Lancamento(
        nome: nome,
        data: data,
        valor: valor,
      );

      gastosDB.addGasto(despesa);
    } else if (parcelasTotal != 0 || fixo) {
      String id = Lancamento(nome: "", data: DateTime.now(), valor: 0).id;

      int qtdParcelas = parcelasTotal;
      if (qtdParcelas == 0) {
        qtdParcelas = 1200;
      }

      List<Lancamento> despesas = List.generate(
        qtdParcelas,
        (parcela) {
          int dia = min(data.day, DateTime(data.year, data.month + parcela + 1, 0).day);
          DateTime dataNow = DateTime(data.year, data.month + parcela, dia);
          return Lancamento(
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
      gastosDB.addListGastos(despesas);
    }
    await getPayments();
  }

  // Remover uma despesa
  Future removeDespesa({
    required String id,
    required int parcela,
    bool removeAll = false,
  }) async {
    if (!removeAll) {
      gastosDB.removeGasto(id, parcela);
    } else {
      List<Lancamento> despesasRemover = gastosDB.gastos.where((e) => (e.id == id && e.parcelaAtual >= parcela)).toList();
      gastosDB.removeListGastos(
        despesasRemover.map((e) => e.id).toList(),
        despesasRemover.map((e) => e.parcelaAtual).toList(),
      );
    }

    await getPayments();
  }

  // Editar uma despesa
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
      gastosDB.editGasto(
        id,
        parcela,
        pago: pago,
        nome: descricao,
        data: data,
        valor: valor,
        fixo: fixo,
      );
    } else {
      //Obtendo as despesas no intervalo
      List<Lancamento> despesasMudar = gastosDB.gastos.where((e) => (e.id == id)).toList();
      if (despesasMudar.isEmpty) {
        return;
      }
      despesasMudar.sort((a, b) => a.parcelaAtual.compareTo(b.parcelaAtual));

      // Removendo as despesas no intervalo para aplicar as modifcações
      gastosDB.removeListGastos(
        despesasMudar.map((e) => e.id).toList(),
        despesasMudar.map((e) => e.parcelaAtual).toList(),
      );

      if (fixo == true) {
        parcelasTotal = 1200;
      }

      List<Lancamento> despesasMudarTemp = [];
      DateTime dataInicial = despesasMudar.first.data;
      int subtrairParcela = 0;

      // Caso o primeiro seja fixo
      if (!fixo && despesasMudar.first.fixo) {
        String newId = Lancamento(nome: "", data: dataInicial, valor: 0).id;

        for (int parcelaAtual = 1; parcelaAtual < parcela; parcelaAtual++) {
          //Data Antiga
          int dia = min(dataInicial.day, DateTime(dataInicial.year, dataInicial.month + parcelaAtual, 0).day);
          DateTime dataAntiga = DateTime(dataInicial.year, dataInicial.month + parcelaAtual - 1, dia);

          // Adicionando a despesa antiga com o novo id
          if (despesasMudar.isNotEmpty && despesasMudar.first.data.compareTo(dataAntiga) == 0) {
            despesasMudarTemp.add(Lancamento(
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

        Lancamento? despesaAdd;
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
          despesaAdd = Lancamento(
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
          despesaAdd = Lancamento(
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

      gastosDB.addListGastos(despesasMudarTemp);
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

      for (Lancamento despesa in despesas) {
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
