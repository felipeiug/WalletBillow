import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:walletbillow/core/models/credit_card/credit_card.dart';

class CreditCardDB {
  static Future<CreditCardDB> init() async {
    await Future.delayed(const Duration(seconds: 3));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return CreditCardDB(prefs);
  }

  SharedPreferences prefs;
  CreditCardDB(this.prefs);

  List<CreditCard> get cards {
    String gastosStr = prefs.getString("cards") ?? "[]";

    List cards_ = jsonDecode(gastosStr);
    List<CreditCard> cards = [];

    for (Map card in cards_) {
      cards.add(CreditCard.fromMap(card));
    }

    return cards;
  }

  set cards(List<CreditCard> value) {
    List<Map> despesasMap = value.map((card) => card.toMap).toList();
    prefs.setString("cards", jsonEncode(despesasMap));
  }

  CreditCard? getCard(String id) {
    var cards_ = cards.where((card) => card.id == id).toList();
    if (cards_.isNotEmpty) return cards_[0];
    return null;
  }

  void addCard(CreditCard card) {
    List<CreditCard> newGastos = cards;
    newGastos.add(card);
    cards = newGastos;
  }

  void removeCard(String id, int parcela) {
    List<CreditCard> newGastos = cards.where((element) => !(element.id == id)).toList();
    cards = newGastos;
  }

  void editCard(
    String id, {
    bool? vencimentoDiaUtil,
    int? diaVencimento,
    bool? melhorDiaParaCompraDiaUtil,
    int? melhorDiaParaCompra,
    String? nomeCartao,
    List<int>? cardNumber,
    String? titular,
    DateTime? validade,
    double? totalLimit,
    List<int>? cor,
  }) {
    List<CreditCard> newGastos = cards.map((element) {
      if (element.id == id) {
        element.vencimentoDiaUtil = vencimentoDiaUtil ?? element.vencimentoDiaUtil;
        element.diaVencimento = diaVencimento ?? element.diaVencimento;
        element.melhorDiaParaCompraDiaUtil = melhorDiaParaCompraDiaUtil ?? element.melhorDiaParaCompraDiaUtil;
        element.nomeCartao = nomeCartao ?? element.nomeCartao;
        element.cardNumber = cardNumber ?? element.cardNumber;
        element.titular = titular ?? element.titular;
        element.validade = validade ?? element.validade;
        element.totalLimit = totalLimit ?? element.totalLimit;
        element.cor = cor ?? element.cor;
      }
      return element;
    }).toList();

    cards = newGastos;
  }
}
