class CreditCard {
  // Dia do vencimento
  bool vencimentoDiaUtil;
  int diaVencimento;

  // Melhor dia Para compra
  bool melhorDiaParaCompraDiaUtil;
  int melhorDiaParaCompra;

  //Dados do cartão
  String nomeCartao;
  List<int> cardNumber;
  String titular;
  DateTime validade;

  CreditCard({
    required this.nomeCartao,
    required this.cardNumber,
    required this.diaVencimento,
    required this.melhorDiaParaCompra,
    this.titular = "",
    this.vencimentoDiaUtil = false,
    this.melhorDiaParaCompraDiaUtil = false,
    DateTime? validade,
  }) : validade = validade ?? DateTime.now();

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
      titular: creditData['titular'] ?? "",
      vencimentoDiaUtil: creditData['vencimentoDiaUtil'] ?? false,
      melhorDiaParaCompraDiaUtil: creditData['melhorDiaParaCompraDiaUtil'] ?? false,
      validade: creditData['validade'] ?? DateTime.now(),
    );
  }

  Map get toMap => {
        "nomeCartao": nomeCartao,
        "numero": cardNumber,
        "titular": titular,
        "validade": validade,
        "diaVencimento": diaVencimento,
        "melhorDiaParaCompra": melhorDiaParaCompra,
        "vencimentoDiaUtil": vencimentoDiaUtil,
        "melhorDiaParaCompraDiaUtil": melhorDiaParaCompraDiaUtil,
      };
}
