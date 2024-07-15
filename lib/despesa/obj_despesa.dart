import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

class Despesa {
  Despesa({
    String? id,
    required this.nome,
    required this.data,
    required this.valor,
    this.pago = false,
    this.parcelasTotal = 0,
    this.parcelaAtual = 0,
    this.fixo = false,
  })  : id = id ?? _getHashString,
        assert(!(fixo && parcelasTotal != 0));

  factory Despesa.fromMap(Map dados) {
    return Despesa(
      id: dados["id"].toString(),
      nome: dados["nome"] ?? "",
      data: DateTime.fromMillisecondsSinceEpoch(dados["data"] ?? DateTime.now().millisecondsSinceEpoch),
      pago: dados["pago"] ?? false,
      valor: dados["valor"] ?? 0,
      fixo: dados["fixo"] ?? false,
      parcelasTotal: dados["parcelasTotal"] ?? 0,
      parcelaAtual: dados["parcelaAtual"] ?? 0,
    );
  }

  Map get toMap {
    return {
      "id": id,
      "nome": nome,
      "data": data.millisecondsSinceEpoch,
      "pago": pago,
      "valor": valor,
      "fixo": fixo,
      "parcelasTotal": parcelasTotal,
      "parcelaAtual": parcelaAtual,
    };
  }

  static String get _getHashString {
    // Obtém a data atual
    DateTime now = DateTime.now();

    // Concatena a data e o ID do dispositivo
    String dataToHash = '$now-WBFelipeiug';

    // Calcula o hash usando o algoritmo SHA-256
    Uint8List hashBytes = Uint8List.fromList(sha256.convert(utf8.encode(dataToHash)).bytes);

    // Converte os bytes do hash para uma string hexadecimal
    String hashString = String.fromCharCodes(hashBytes);

    return hashString;
  }

  Despesa copy() {
    return Despesa(
      nome: nome,
      data: data,
      valor: valor,
      pago: pago,
      parcelasTotal: parcelasTotal,
      parcelaAtual: parcelaAtual,
      fixo: fixo,
    );
  }

  static const int despesa = -1;
  static const int receita = 1;

  final String id;
  String nome;
  DateTime data;
  double valor;
  bool pago;
  bool fixo;
  int parcelasTotal;
  int parcelaAtual;

  @override
  String toString() => "Despesa(id: $id, parcela: $parcelaAtual/$parcelasTotal, fixo: $fixo, valor: $valor)";

  bool inDateTimeRange(DateTimeRange dateRange) {
    if (data.compareTo(dateRange.start) >= 0 && data.compareTo(dateRange.end) <= 0) {
      return true;
    }
    return false;
  }
}
