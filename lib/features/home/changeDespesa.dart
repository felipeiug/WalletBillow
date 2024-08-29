import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:walletbillow/core/models/lancamentos/lancamento.dart';
import 'package:walletbillow/shared/themes/widgets.dart';
import 'package:walletbillow/core/utils/home_config.dart';

void changeDispesa(
  BuildContext context,
  HomeUtil config, {
  Lancamento? despesa,
  Function? onValue,
}) async {
  showDialog(
    context: context,
    builder: (context) {
      //Checando se está modificando ou criando
      bool modificando = despesa != null;

      TextEditingController controllerDescricao = TextEditingController(
        text: (despesa?.nome ?? ""),
      );
      TextEditingController controllerValor = TextEditingController(
        text: (despesa?.valor ?? 0).toStringAsFixed(2).replaceAll(".", ",").replaceAll("-", ""),
      );
      TextEditingController controllerParcelas = TextEditingController(
        text: (despesa?.parcelasTotal ?? 0).toString(),
      );

      int tipoDespesa = (despesa?.valor ?? 0) < 0 ? -1 : 1;
      bool fixo = despesa?.fixo ?? false;
      DateTime data = despesa?.data ?? DateTime.now();

      return AlertDialog(
        title: Text(modificando ? "Alterar Lancamento" : "Novo Lancamento"),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Divisor
                  const Divider(),

                  //Descrição
                  const Text("Breve Descrição:"),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 56,
                    child: TextField(
                      controller: controllerDescricao,
                      decoration: const InputDecoration(
                        hintText: "Descrição",
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

                  //Valor
                  const Text("Valor:"),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 56,
                    child: TextField(
                      controller: controllerValor,
                      decoration: InputDecoration(
                        filled: false,
                        prefix: SizedBox(
                          width: 76,
                          child: Row(
                            children: [
                              const Text("R\$"),
                              Transform.scale(
                                scale: 0.8,
                                child: IconButton(
                                    icon: Icon(
                                      tipoDespesa == -1 ? Icons.remove : Icons.add,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        tipoDespesa = tipoDespesa == -1 ? 1 : -1;
                                      });
                                    }),
                              ),
                            ],
                          ),
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        bool minus = value.contains("-");
                        bool plus = value.contains("+");

                        String numero = value.replaceAll(RegExp("[,.+-]"), "");
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

                        // Caso seja negativo
                        if (minus) {
                          setState(() {
                            tipoDespesa = -1;
                          });
                        } else if (plus) {
                          setState(() {
                            tipoDespesa = 1;
                          });
                        }

                        controllerValor.text = numero;
                      },
                    ),
                  ),
                  const Divider(),

                  // Pagamento fixo
                  Row(
                    children: [
                      Text("${tipoDespesa == -1 ? "Despesa" : "Receita"} Fixa:"),
                      const Spacer(),
                      Checkbox(
                        value: fixo,
                        onChanged: (value) {
                          setState(() {
                            fixo = !fixo;
                            if (fixo) {
                              controllerParcelas.text = "";
                            }
                          });
                        },
                      )
                    ],
                  ),
                  const Divider(),

                  // Pagamento parcelado
                  fixo ? const SizedBox() : const Text("Parcelas:"),
                  fixo
                      ? const SizedBox()
                      : SizedBox(
                          height: 56,
                          child: TextField(
                            controller: controllerParcelas,
                            decoration: const InputDecoration(
                              filled: false,
                              prefix: Text("X    "),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            onChanged: (value) {
                              String numero = value.replaceAll(RegExp("[,.+-]"), "");
                              numero = (int.tryParse(numero) ?? 0).toString();
                              controllerParcelas.text = numero;
                            },
                          ),
                        ),
                  fixo ? const SizedBox() : const Divider(),

                  // Data
                  Row(
                    children: [
                      const Text("Data:"),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () async {
                          DateTime? dataNow = await showDatePicker(
                            context: context,
                            firstDate: DateTime(0),
                            lastDate: DateTime(DateTime.now().year + 9999),
                            initialDate: data,
                          );

                          if (dataNow != null) {
                            setState(() {
                              data = dataNow;
                            });
                          }
                        },
                        child: Text(
                          DateFormat('dd/MM/yyyy', 'pt_BR').format(data),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                ],
              ),
            );
          },
        ),
        actions: [
          //Cancelar
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancelar"),
          ),

          // Espaçador
          const SizedBox(
            width: 5,
            height: 5,
          ),

          //Adicionar ou aplicar a todos
          if (!modificando || despesa.parcelasTotal > 0 || despesa.fixo)
            ElevatedButton(
              onPressed: () async {
                double valor = 0;

                if (controllerDescricao.text.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return const AlertDialog(
                        title: Text("Erro"),
                        content: Text("Adicione uma descrição!"),
                      );
                    },
                  );
                  return;
                }
                if (controllerValor.text.isEmpty || (double.tryParse(controllerValor.text.replaceAll(",", ".")) ?? 0) == 0) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return const AlertDialog(
                        title: Text("Erro"),
                        content: Text("O valor da despesa deve ser diferente de 0."),
                      );
                    },
                  );
                  return;
                } else {
                  valor = double.tryParse(controllerValor.text.replaceAll(",", ".")) ?? 0;
                  if (tipoDespesa == -1) {
                    valor *= -1;
                  }
                }

                int? parcelasTotal = int.tryParse(controllerParcelas.text.replaceAll(",", "."));

                if (!modificando) {
                  await config.addDespesa(
                    nome: controllerDescricao.text,
                    data: data,
                    valor: valor,
                    parcelasTotal: parcelasTotal ?? 0,
                    fixo: (parcelasTotal ?? 0) == 0 && fixo,
                  );
                } else {
                  await config.editDespesa(
                    id: despesa.id,
                    parcela: despesa.parcelaAtual,
                    descricao: controllerDescricao.text,
                    data: data,
                    valor: valor,
                    parcelasTotal: parcelasTotal ?? despesa.parcelasTotal,
                    fixo: (parcelasTotal ?? 0) == 0 && fixo,
                    pago: despesa.pago,
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  Navigator.of(context).pop();
                });
              },
              child: Text(modificando ? "Alterar toda a série" : "Adicionar"),
            ),

          // Espaçador
          const SizedBox(
            width: 5,
            height: 5,
          ),

          // Alterar somente este mês
          if (modificando)
            ElevatedButton(
              onPressed: () async {
                double valor = 0;

                if (controllerDescricao.text.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return const AlertDialog(
                        title: Text("Erro"),
                        content: Text("Adicione uma descrição!"),
                      );
                    },
                  );
                  return;
                }
                if (controllerValor.text.isEmpty || (double.tryParse(controllerValor.text.replaceAll(",", ".")) ?? 0) == 0) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return const AlertDialog(
                        title: Text("Erro"),
                        content: Text("O valor da despesa deve ser diferente de 0."),
                      );
                    },
                  );
                  return;
                } else {
                  valor = double.tryParse(controllerValor.text.replaceAll(",", ".")) ?? 0;
                  if (tipoDespesa == -1) {
                    valor *= -1;
                  }
                }

                int? parcelasTotal = int.tryParse(controllerParcelas.text.replaceAll(",", "."));
                if (parcelasTotal != despesa.parcelasTotal) {
                  bool confirm = await Widgets.confimation(
                    context,
                    title: "Impossível alterar as parcelas",
                    subtitle: "Quando modificar apenas um mês não é possível alterar a quantidade de parcelas.\nDeseja continuar sem alterar as parcelas?",
                  );

                  if (!confirm) {
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                      Navigator.of(context).pop();
                    });
                    return;
                  }
                }

                if (despesa.fixo != fixo) {
                  bool confirm = await Widgets.confimation(
                    context,
                    title: "Impossível alterar o fixo",
                    subtitle: "Quando modificar apenas um mês não é possível alterar se é fixo ou não fixo.\nDeseja continuar sem alterar o estado?",
                  );

                  if (!confirm) {
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                      Navigator.of(context).pop();
                    });
                    return;
                  }
                }

                await config.editDespesa(
                  id: despesa.id,
                  parcela: despesa.parcelaAtual,
                  editAll: false,
                  parcelasTotal: 0,
                  descricao: controllerDescricao.text,
                  data: data,
                  valor: valor,
                  fixo: (parcelasTotal ?? 0) == 0 && fixo,
                  pago: despesa.pago,
                );

                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  Navigator.of(context).pop();
                });
              },
              child: Text(despesa.parcelasTotal > 0 || despesa.fixo ? "Alterar somente este mês" : "Alterar Lancamento"),
            ),
        ],
      );
    },
  ).then((value) => onValue != null ? onValue() : null);
}
