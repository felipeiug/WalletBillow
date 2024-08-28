import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:walletbillow/paleta/cores.dart';
import 'package:walletbillow/telas/home/home_config.dart';

Widget grafico(HomeConfig config) {
    //0 - Receitas
    //1 - Gastos
    //2 - Diferença
    List<List<FlSpot>> spots = config.receitaDespesaSpot;

    Widget grafic = LineChart(
      LineChartData(
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          // Receitas
          LineChartBarData(
            spots: spots[0],
            color: Cores.bom,
            dotData: const FlDotData(show: false),
          ),
          // Gastos
          LineChartBarData(
            spots: spots[1],
            color: Cores.ruim,
            dotData: const FlDotData(show: false),
          ),
          // Diferença
          LineChartBarData(
            spots: spots[2],
            color: Cores.primaria,
            dotData: const FlDotData(show: false),
          ),
        ],
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            axisNameSize: 5,
            axisNameWidget: const SizedBox(),
          ),
          topTitles: const AxisTitles(axisNameWidget: Text("Balanço Mensal"), axisNameSize: 26),
          bottomTitles: AxisTitles(
            axisNameWidget: const Text(
              "Dia",
              style: TextStyle(fontSize: 12),
            ),
            sideTitles: SideTitles(
              interval: config.despesas.isEmpty ? 1E12 : max(config.dateTimeRange.duration.inMicroseconds / 5, 1),
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value == config.dateTimeRange.start.microsecondsSinceEpoch) {
                  return const SizedBox();
                }
                return Text(
                  DateFormat("dd/MMM", 'pt-BR').format(
                    DateTime.fromMicrosecondsSinceEpoch(value.toInt()),
                  ),
                  style: const TextStyle(fontSize: 8),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            axisNameWidget: Text(
              "Gastos (R\$)",
              style: TextStyle(fontSize: 10),
            ),
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
      ),
    );

    return Expanded(child: grafic);
  }

  