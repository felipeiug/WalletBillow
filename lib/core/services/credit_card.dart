import 'dart:convert';
import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:walletbillow/core/models/credit_card/credit_card.dart';

class CreditCardDB {
  static Future<CreditCardDB> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return CreditCardDB(prefs);
  }

  SharedPreferences prefs;
  CreditCardDB(this.prefs);

  set creditCardColors(List<Color> colors) {
    List<int> colors_ = colors.map((color) => color.toARGB32()).toList();
    prefs.setString("cardColors", jsonEncode(colors_));
  }

  List<Color> get creditCardColors {
    String? colorsStr = prefs.getString("cardColors");

    List<Color> colorsInit = [
      Color(0xFFFFD700), // Dourado
      Color.fromRGBO(212, 175, 55, 1),
      Color(0xFFFFD700),
      Color(0xFFC0C0C0),
      Color(0xFF1976D2), // Azul clássico
      Color(0xFF003366), // Azul marinho
      Color(0xFF263238), // Preto elegante
      Color(0xFFD32F2F), // Vermelho intenso
      Color(0xFF388E3C), // Verde corporativo
      Color(0xFF6A1B9A), // Roxo premium
      Color(0xFF607D8B), // Cinza metálico
      Color(0xFF795548), // Marrom couro
      Color(0xFFE91E63), // Rosa vibrante
      Color(0xFF4CAF50), // Verde claro
      Color(0xFF9C27B0), // Roxo médio
      Color(0xFF0D47A1), // Azul profundo
      Color(0xFFC2185B), // Rosa escuro
      Color(0xFF2E7D32), // Verde escuro
      Color(0xFF455A64), // Cinza-azulado
    ];

    if (colorsStr == null) return colorsInit;

    List colors_ = jsonDecode(colorsStr);
    List<Color> colors = colors_.map((color) => Color(color)).toList();
    return colors;
  }

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
    String? cardNumber,
    String? titular,
    DateTime? validade,
    int? totalLimit,
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
