import 'dart:async';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:walletbillow/core/services/config_data.dart';
import 'package:walletbillow/shared/themes/cores.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({
    super.key,
  });

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final GlobalKey buttonKey = GlobalKey();

  RelativeRect getRelativeRect(GlobalKey key) {
    RenderBox box = key.currentContext?.findRenderObject() as RenderBox;
    Offset offset = box.localToGlobal(Offset.zero);
    Size size = box.size;
    final RenderBox overlay = Overlay.of(key.currentContext!).context.findRenderObject() as RenderBox;
    RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        offset,
        offset.translate(size.width, size.height),
      ),
      Offset.zero & overlay.size,
    );
    return position;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const FittedBox(
          fit: BoxFit.fitHeight,
          child: Text(
            "Configurações",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        leadingWidth: 40,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Dia do Pagamento
              Card(
                child: ListTile(
                  title: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Dia de pagamento:",
                        ),
                      ),
                      OutlinedButton(
                        key: buttonKey,
                        onPressed: () async {
                          RelativeRect position = getRelativeRect(buttonKey);

                          int? dia = await showMenu(
                            context: context,
                            position: position,
                            constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height * 0.5,
                            ),
                            items: List.generate(
                              25,
                              (index) => PopupMenuItem(
                                value: index + 1,
                                child: SizedBox(
                                  width: 56,
                                  child: Center(
                                    child: Text((index + 1).toString()),
                                  ),
                                ),
                              ),
                            ),
                          );

                          if (dia != null) {
                            Config.diaPagamento = dia;
                            setState(() {});
                          }
                        },
                        child: Text(Config.diaPagamento.toString()),
                      ),
                    ],
                  ),
                ),
              ),

              //Gasto máximo
              Card(
                child: ListTile(
                  title: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Limite máximo de gasto:",
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: OutlinedButton(
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(EdgeInsets.zero),
                          ),
                          onPressed: () async {
                            double? gasto = await showDialog(
                              context: context,
                              builder: (context) {
                                Timer textoTimer = Timer.periodic(
                                  const Duration(seconds: 2),
                                  (timer) {
                                    timer.cancel();
                                  },
                                );
                                TextEditingController controller = TextEditingController(
                                  text: "R\$${Config.gastoMax.toStringAsFixed(2)}".replaceAll(".", ","),
                                );
                                return AlertDialog(
                                  title: const Text("Valor Máximo dos Gastos:"),
                                  content: SizedBox(
                                    height: 76,
                                    child: TextField(
                                      controller: controller,
                                      onChanged: (value) {
                                        textoTimer.cancel();
                                        textoTimer = Timer.periodic(
                                          const Duration(seconds: 2),
                                          (timer) {
                                            value = value.replaceAll(" ", "").replaceAll("R", "").replaceAll("\$", "").replaceAll(",", ".");
                                            double val = double.tryParse(value) ?? 0;
                                            controller.text = "R\$ ${val.toStringAsFixed(2)}".replaceAll(".", ",");
                                            timer.cancel();
                                          },
                                        );
                                      },
                                      onEditingComplete: () {
                                        String value = controller.text.replaceAll(" ", "").replaceAll("R", "").replaceAll("\$", "").replaceAll(",", ".");
                                        double val = double.tryParse(value) ?? 0;
                                        controller.text = "R\$ ${val.toStringAsFixed(2)}".replaceAll(".", ",");
                                      },
                                    ),
                                  ),
                                  actions: [
                                    OutlinedButton(
                                      onPressed: () {
                                        String value = controller.text.replaceAll(" ", "").replaceAll("R", "").replaceAll("\$", "").replaceAll(",", ".");
                                        double val = double.tryParse(value) ?? 0;
                                        Navigator.of(context).pop(val);
                                      },
                                      child: const Text("Feito"),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (gasto != null) {
                              Config.gastoMax = gasto;
                              setState(() {});
                            }
                          },
                          child: Text(
                            "R\$${Config.gastoMax.toStringAsFixed(2)}".replaceAll(".", ","),
                            style: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              //Variáveis de visualização
              const Divider(),

              //Texto do thema
              const Text("Tema:"),

              //Botões do Thema
              Card(
                child: ListTile(
                  title: IconButtonTheme(
                    data: IconButtonThemeData(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        iconSize: MaterialStateProperty.all(36),
                      ),
                    ),
                    child: Row(
                      children: [
                        //Automático
                        IconButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Config.thema.isSystem ? Cores.escuro : Cores.branco,
                            ),
                          ),
                          onPressed: () {
                            Config.thema = AdaptiveThemeMode.system;
                            AdaptiveTheme.of(context).setLight();
                            setState(() {});
                          },
                          icon: Icon(
                            Config.thema.isSystem ? Icons.smartphone_outlined : Icons.smartphone_rounded,
                            color: Config.thema.isSystem ? Cores.branco : Cores.escuro,
                          ),
                        ),

                        const Spacer(),

                        //Claro
                        IconButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Config.thema.isLight ? Cores.escuro : Cores.branco,
                            ),
                          ),
                          onPressed: () {
                            Config.thema = AdaptiveThemeMode.light;
                            AdaptiveTheme.of(context).setLight();
                            setState(() {});
                          },
                          icon: Icon(
                            Config.thema.isLight ? Icons.light_mode : Icons.light_mode_outlined,
                            color: Config.thema.isLight ? Cores.branco : Cores.escuro,
                          ),
                        ),

                        const Spacer(),

                        //Escuro
                        IconButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Config.thema.isDark ? Cores.escuro : Cores.branco,
                            ),
                          ),
                          onPressed: () {
                            Config.thema = AdaptiveThemeMode.dark;
                            AdaptiveTheme.of(context).setDark();
                            setState(() {});
                          },
                          icon: Icon(
                            Config.thema.isDark ? Icons.dark_mode : Icons.dark_mode_outlined,
                            color: Config.thema.isDark ? Cores.branco : Cores.escuro,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              //Variáveis de controle
              // const Divider(),

              //TODO: Implementar a forma de apagar todas as despesas
              // Card(
              //   child: ListTile(
              //     title: Row(
              //       children: [
              //         const Expanded(
              //           child: Text(
              //             "Excluir todas as despesas",
              //           ),
              //         ),
              //         IconButton(
              //           onPressed: () async {
              //             if (await Widgets.confimation(
              //               context,
              //               title: "Deseja mesmo apagar todas as suas despesas?",
              //               subtitle: "Isto irá apagar todas as suas despesas! Esta ação não é reversível!",
              //             )) {
              //               Config.gastos.gastos = [];
              //             }
              //           },
              //           icon: const Icon(
              //             Icons.delete_forever,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),

              //Espaçador
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
