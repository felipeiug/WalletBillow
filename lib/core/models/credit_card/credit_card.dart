import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:u_credit_card/u_credit_card.dart';
import 'package:walletbillow/core/models/lancamentos/lancamento.dart';

class CreditCard {
  final String id;

  // Dia do vencimento
  bool vencimentoDiaUtil;
  int diaVencimento;

  // Melhor dia Para compra
  bool melhorDiaParaCompraDiaUtil;
  int melhorDiaParaCompra;

  //Dados do cartão
  String nomeCartao;
  String cardNumber;
  String titular;
  DateTime validade;
  int totalLimit;

  // Estilo do cartão
  List<int> cor;

  CreditCard({
    String? id,
    required this.nomeCartao,
    required this.cardNumber,
    required this.diaVencimento,
    required this.melhorDiaParaCompra,
    required this.totalLimit,
    this.cor = const [255, 255, 255],
    this.titular = "",
    this.vencimentoDiaUtil = false,
    this.melhorDiaParaCompraDiaUtil = false,
    DateTime? validade,
  })  : id = id ?? _getHashString,
        validade = validade ?? DateTime.now();

  factory CreditCard.fromMap(Map creditData) {
    if (!creditData.containsKey("nomeCartao")) {
      throw Exception("Os dados devem conter o nome do Cartão");
    } else if (!creditData.containsKey("numero")) {
      throw Exception("Os dados devem conter o numero do Cartão");
    } else if (!creditData.containsKey("diaVencimento")) {
      throw Exception("Os dados devem conter o dia de vencimento do Cartão");
    } else if (!creditData.containsKey("melhorDiaParaCompra")) {
      throw Exception("Os dados devem conter o melhor dia para compra do Cartão");
    }

    return CreditCard(
      nomeCartao: creditData['nomeCartao'],
      cardNumber: creditData['numero'],
      diaVencimento: creditData['diaVencimento'],
      melhorDiaParaCompra: creditData['melhorDiaParaCompra'],
      totalLimit: creditData["totalLimit"],
      cor: creditData['cor'],
      titular: creditData['titular'] ?? "",
      vencimentoDiaUtil: creditData['vencimentoDiaUtil'] ?? false,
      melhorDiaParaCompraDiaUtil: creditData['melhorDiaParaCompraDiaUtil'] ?? false,
      validade: creditData['validade'] ?? DateTime.now(),
    );
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

  static CreditCardType detectCardType(String cardNumber) {
    // Remove todos os espaços e caracteres não numéricos
    final cleanedNumber = cardNumber.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanedNumber.isEmpty) return CreditCardType.none;

    // Visa (começa com 4)
    if (RegExp(r'^4').hasMatch(cleanedNumber)) {
      return CreditCardType.visa;
    }

    // Mastercard (51-55 ou 2221-2720)
    if (RegExp(r'^5[1-5]').hasMatch(cleanedNumber) || RegExp(r'^2[2-7][2-9][0-9]').hasMatch(cleanedNumber)) {
      return CreditCardType.mastercard;
    }

    // Amex (34 ou 37)
    if (RegExp(r'^3[47]').hasMatch(cleanedNumber)) {
      return CreditCardType.amex;
    }

    // Discover (6011, 644-649, 65)
    if (RegExp(r'^6011').hasMatch(cleanedNumber) || RegExp(r'^64[4-9]').hasMatch(cleanedNumber) || RegExp(r'^65').hasMatch(cleanedNumber)) {
      return CreditCardType.discover;
    }

    return CreditCardType.none;
  }

  double? _gastoTotal;
  set gastoTotal(double val) {
    _gastoTotal = val;
  }

  double get gastoTotal {
    return _gastoTotal ?? 0;
  }

  bool despesaInMonth(Lancamento lancamento, DateTimeRange range) {
    if (lancamento.cartao != id) {
      return false;
    }

    // Ver com o range de datas, o range deste cartão.
    // Com isto da pra saber se a data do lançamento está na mesma data deste cartão.

    // if (data.compareTo(dateRange.start) >= 0 && data.compareTo(dateRange.end) <= 0) {
    //   return true;
    // }
    // return false;
    return true;
  }

  Map get toMap => {
        "id": id,
        "nomeCartao": nomeCartao,
        "numero": cardNumber,
        "titular": titular,
        "totalLimit": totalLimit,
        "cor": cor,
        "validade": validade,
        "diaVencimento": diaVencimento,
        "melhorDiaParaCompra": melhorDiaParaCompra,
        "vencimentoDiaUtil": vencimentoDiaUtil,
        "melhorDiaParaCompraDiaUtil": melhorDiaParaCompraDiaUtil,
      };
}
