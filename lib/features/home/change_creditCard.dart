import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import 'package:u_credit_card/u_credit_card.dart';
import 'package:walletbillow/core/models/credit_card/credit_card.dart';
import 'package:walletbillow/core/models/lancamentos/lancamento.dart';
import 'package:walletbillow/shared/themes/widgets.dart';
import 'package:walletbillow/core/utils/home_config.dart';
import 'package:walletbillow/shared/widgets/color_picker.dart';

class CreditCardScreen extends StatefulWidget {
  const CreditCardScreen(
    this.config, {
    super.key,
    this.cartao,
  });

  final HomeUtil config;
  final CreditCard? cartao;

  @override
  State<CreditCardScreen> createState() => _CreditCardState();
}

class _CreditCardState extends State<CreditCardScreen> {
  // Dados do cartão
  CreditCard? cartao;

  //Checando se está modificando ou criando
  late bool modificando;

  late int diaVencimento;
  late int melhorDiaParaCompra;
  late DateTime validade;

  // Estilo do cartão
  late Color cor = Color.fromARGB(
    cartao?.cor[0] ?? 255,
    cartao?.cor[1] ?? 128,
    cartao?.cor[2] ?? 59,
    cartao?.cor[3] ?? 179,
  );

  late TextEditingController controllerNomeCartao;
  late TextEditingController controllerCardNumber;
  late TextEditingController controllerTitular;
  late TextEditingController controllerTotalLimit;

  @override
  void initState() {
    super.initState();

    cartao = widget.cartao;

    modificando = cartao != null;

    diaVencimento = cartao?.diaVencimento ?? 15;
    melhorDiaParaCompra = cartao?.melhorDiaParaCompra ?? 15;
    validade = cartao?.validade ?? (DateTime.now().add(const Duration(days: 365 * 2)));

    cor = Color.fromARGB(
      cartao?.cor[0] ?? 255,
      cartao?.cor[1] ?? 128,
      cartao?.cor[2] ?? 59,
      cartao?.cor[3] ?? 179,
    );

    controllerNomeCartao = TextEditingController(
      text: (cartao?.nomeCartao ?? ""),
    );
    controllerCardNumber = TextEditingController(
      text: (cartao?.cardNumber ?? ""),
    );
    controllerTitular = TextEditingController(
      text: (cartao?.titular ?? ""),
    );
    controllerTotalLimit = TextEditingController(
      text: (cartao?.totalLimit ?? 2500).toStringAsFixed(2).replaceAll(".", ",").replaceAll("-", ""),
    );
  }

  String getValidateString() {
    return "${validade.month.toString().padRight(2, "0")}/${validade.year.toString().substring(2)}";
  }

  void onfinish() {
    Navigator.pop(context, cartao);
  }

  @override
  Widget build(BuildContext context) {
    const descStyle = TextStyle(fontSize: 18);

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              // Título
              Row(
                children: [
                  Text(
                    modificando ? "Alterar Cartão" : "Novo Cartão",
                    style: TextStyle(fontSize: 28),
                  ),
                  Spacer(),
                  Tooltip(
                    message: "Nenhuma informação será enviada ou armazenada em nossos servidores.",
                    child: Icon(Icons.help),
                  ),
                ],
              ),
              const Divider(),

              // Visualização do cartão
              CreditCardUi(
                cardHolderFullName: controllerTitular.text,
                cardNumber: controllerCardNumber.text,
                validThru: getValidateString(),
                topLeftColor: cor,
                bottomRightColor: cor.darken(30),
                showValidFrom: false,
                currencySymbol: "R\$",
                showBalance: true,
                balance: double.tryParse(controllerTotalLimit.text.replaceAll(",", ".")) ?? 2500.0,
              ),

              // Items
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Divisor
                    const Divider(),

                    //Apelido e Cor
                    SizedBox(
                      height: 86,
                      child: Row(
                        children: [
                          // Apelido
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Apelido:", style: descStyle),
                                SizedBox(
                                  height: 56,
                                  child: TextField(
                                    controller: controllerNomeCartao,
                                    onChanged: (_) => setState(() {}),
                                    decoration: const InputDecoration(
                                      hintText: "Apelido",
                                      filled: false,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Cor do Cartão
                          Expanded(
                            child: Column(
                              children: [
                                const Text("Cor:", style: descStyle),
                                IconButton(
                                  onPressed: () async {
                                    Color? newColor = await showPickerColor(context, initialColor: cor);
                                    if (newColor == null) return;
                                    setState(() {
                                      cor = newColor;
                                    });
                                  },
                                  icon: Icon(Icons.square, color: cor, size: 35),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),

                    //Número do Cartão
                    const Text("Número:", style: descStyle),
                    const SizedBox(height: 5),
                    SizedBox(
                      height: 56,
                      child: TextField(
                        controller: controllerCardNumber,
                        onChanged: (value) {
                          var number = value.replaceAll(RegExp(r'[^\d]'), '');
                          if (number.length == 15) {
                            number = number.replaceAllMapped(
                              RegExp(r'(\d{4})(\d{6})(\d{5})'),
                              (match) => '${match[1]} ${match[2]} ${match[3]}',
                            );
                          } else {
                            number = number.replaceAllMapped(
                              RegExp(r'(\d{4})(\d{4})(\d{4})(\d{4})'),
                              (match) => '${match[1]} ${match[2]} ${match[3]} ${match[4]}',
                            );
                          }
                          controllerCardNumber.text = number;
                          setState(() => {});
                        },
                        decoration: const InputDecoration(
                          hintText: "Número",
                          filled: false,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: TextInputType.name,
                      ),
                    ),
                    const Divider(),

                    // Titular a limite
                    SizedBox(
                      height: 86,
                      child: Row(
                        children: [
                          // Titular
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Titular:", style: descStyle),
                                SizedBox(
                                  height: 56,
                                  child: TextField(
                                    controller: controllerTitular,
                                    onChanged: (_) => setState(() {}),
                                    decoration: const InputDecoration(
                                      hintText: "Titular",
                                      filled: false,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    keyboardType: TextInputType.name,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Limite
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Limite:", style: descStyle),
                                SizedBox(
                                  height: 56,
                                  child: TextField(
                                    controller: controllerTotalLimit,
                                    decoration: InputDecoration(
                                      filled: false,
                                      prefix: SizedBox(
                                        width: 26,
                                        child: const Text("R\$"),
                                      ),
                                      border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      String numero = value.replaceAll(RegExp(r'[^\d]'), '');
                                      if (numero.length <= 2) {
                                        numero = numero.padLeft(3, "0");
                                      }
                                      numero = "${numero.substring(0, numero.length - 2)},${numero.substring(numero.length - 2, numero.length)}";

                                      //Adicionado os zeros a esquerda
                                      numero = (int.tryParse(numero.replaceAll(",", "")) ?? 0).toString();
                                      if (numero.length <= 2) {
                                        numero = numero.padLeft(3, "0");
                                      }
                                      numero = "${numero.substring(0, numero.length - 2)},${numero.substring(numero.length - 2, numero.length)}";

                                      setState(() {
                                        controllerTotalLimit.text = numero;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),

                    // Validade
                    const Text("Validade:", style: descStyle),
                    SizedBox(
                      height: 86,
                      child: Row(
                        children: [
                          // Mês
                          SizedBox(
                            width: 26,
                            child: TextField(
                              controller: TextEditingController(text: cartao?.validade.month.toString().padRight(2, "0") ?? ""),
                              onChanged: (_) => setState(() {
                                DateTime date = 
                                cartao?.validade.month.toString().padRight(2, "0") ?? ""
                              }),
                              decoration: const InputDecoration(filled: false),
                              keyboardType: TextInputType.datetime,
                            ),
                          ),
                          Text("/"),
                          // Ano
                          SizedBox(
                            height: 56,
                            width: 26,
                            child: TextField(
                              controller: controllerTitular,
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(filled: false),
                              keyboardType: TextInputType.datetime,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
