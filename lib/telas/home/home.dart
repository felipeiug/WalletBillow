import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walletbillow/configuracoes/config_data.dart';
import 'package:walletbillow/despesa/obj_despesa.dart';
import 'package:walletbillow/main.dart';
import 'package:walletbillow/paleta/cores.dart';
import 'package:intl/intl.dart';
import 'package:walletbillow/paleta/widgets.dart';
import 'package:walletbillow/telas/home/home_config.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //Mostrar o gráfico
  bool showGrafico = false;
  //Altura do botão que mostra o gráfico
  double alturaBotaoGrafico = 56;
  //Configurações do gráfico
  late GraficConfig configuracoesGrafico;

  //Configuracoes do home
  late HomeConfig config;

  // Animação finalizada
  bool animateFinish = false;

  //Key para controlar o drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void openOptions() async {
    await Navigator.of(context).pushNamed("/configuracoes");
    await config.getPayments();
    setState(() {});
  }

  void changeDispesa({Despesa? despesa}) async {
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
          title: Text(modificando ? "Alterar Despesa" : "Nova Despesa"),
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
                                        tipoDespesa == Despesa.despesa ? Icons.remove : Icons.add,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          tipoDespesa = tipoDespesa == Despesa.despesa ? Despesa.receita : Despesa.despesa;
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
                              tipoDespesa = Despesa.despesa;
                            });
                          } else if (plus) {
                            setState(() {
                              tipoDespesa = Despesa.receita;
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
                        Text("${tipoDespesa == Despesa.despesa ? "Despesa" : "Receita"} Fixa:"),
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
                    if (tipoDespesa == Despesa.despesa) {
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
                    if (tipoDespesa == Despesa.despesa) {
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
                child: Text(despesa.parcelasTotal > 0 || despesa.fixo ? "Alterar somente este mês" : "Alterar Despesa"),
              ),
          ],
        );
      },
    ).then((value) => setState(() {}));
  }

  Widget get grafico {
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

  List<Widget> get getWidgetsDrawer {
    return <Widget>[
      //Titulo do Drawer
      DrawerHeader(
        duration: const Duration(seconds: 5),
        child: Row(
          children: [
            //Foto do Wallet billow
            PhotoHero(
              height: 56,
              onTap: () {
                _scaffoldKey.currentState!.openDrawer();
              },
              photo: Config.thema.isDark ? "assets/WB_bg_dark.png" : "assets/WB_bg_light.png",
            ),

            //Espaçador
            const SizedBox(width: 15),

            //Texto Animado
            AnimatedTextKit(
              animatedTexts: [
                TyperAnimatedText(
                  "Wallet Billow",
                  speed: const Duration(milliseconds: 250),
                  // textStyle: Fontes.titulos(
                  //   fontSize: 22,
                  // ),
                ),
              ],
              isRepeatingAnimation: false,
              totalRepeatCount: 10,
              stopPauseOnTap: false,
              displayFullTextOnTap: true,
            ),
          ],
        ),
      ),

      //Icone do inicio
      ListTile(
        onTap: () {
          _scaffoldKey.currentState!.closeDrawer();
        },
        //iconColor: Cores.escuro,
        leading: const Icon(Icons.home),
        title: const Text("Início"),
      ),

      //Icone entre em contato
      ListTile(
        onTap: () async {
          String? encodeQueryParameters(Map<String, String> params) {
            return params.entries.map((MapEntry<String, String> e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');
          }

          Uri url = Uri(
            scheme: "mailto",
            path: "felipeiug@hotmail.com",
            query: encodeQueryParameters(
              {
                "subject": "Dúvida sobre o Wallet Billow",
              },
            ),
          );

          launchUrl(url);
        },
        leading: const Icon(Icons.email),
        title: const Text("Contato"),
      ),

      //Icone sobre
      ListTile(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AboutDialog(
              applicationName: "Wallet Billow",
              applicationVersion: versaoDoApp,
              applicationIcon: PhotoHero(
                height: 36,
                width: 36,
                photo: Config.thema.isDark ? "assets/WB_bg_dark.png" : "assets/WB_bg_light.png",
                onTap: () {},
              ),
              applicationLegalese: "©Todos os direitos reservados.",
            ),
          );
        },
        leading: const Icon(Icons.help),
        title: const Text("Sobre"),
      ),

      //Divisor
      const Divider(),

      //Icone sair
      ListTile(
        onTap: () {
          if (Platform.isAndroid) {
            SystemNavigator.pop(
              animated: true,
            );
          } else if (Platform.isIOS) {
            exit(0);
          }
        },
        //iconColor: Cores.escuro,
        leading: const Icon(Icons.logout),
        title: const Text("Sair"),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();

    //Iniciando as configurações
    config = HomeConfig();
    config.getPayments();
    Future.delayed(Durations.long2).then((value) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      autofocus: true,
      focusNode: FocusNode(),
      onKey: (value) async {
        if (value.isAltPressed && value.character == "c" && !value.repeat) {
          if (Config.thema == AdaptiveThemeMode.dark) {
            Config.thema = AdaptiveThemeMode.light;
            AdaptiveTheme.of(context).setLight();
          } else {
            Config.thema = AdaptiveThemeMode.dark;
            AdaptiveTheme.of(context).setDark();
          }
        }
      },
      child: Scaffold(
        key: _scaffoldKey,

        //Drawer
        drawer: Drawer(
          width: MediaQuery.of(context).size.width * 0.8,
          elevation: 12,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
            child: ListView.builder(
              itemCount: getWidgetsDrawer.length,
              itemBuilder: (context, index) {
                return getWidgetsDrawer[index];
              },
            ),
          ),
        ),

        //App bar
        appBar: AppBar(
          title: const FittedBox(
            fit: BoxFit.fitHeight,
            child: Text(
              "Wallet Billow",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          leadingWidth: 40,
          leading: PhotoHero(
            onTap: () {
              _scaffoldKey.currentState!.openDrawer();
            },
            photo: Config.thema.isDark ? "assets/WB_bg_dark.png" : "assets/WB_bg_light.png",
          ),
          actions: [
            IconButton(
              onPressed: openOptions,
              icon: const Icon(
                Icons.settings,
                //color: Cores.escuro,
              ),
            ),
          ],
        ),

        //Coluna com os dados
        body: Builder(
          builder: (context) {
            int lenDespesas = config.despesas.length;

            return Container(
              padding: const EdgeInsets.all(0),
              child: Column(
                children: [
                  //Gráfico
                  Card(
                    margin: const EdgeInsets.all(0),
                    elevation: 8,
                    surfaceTintColor: Theme.of(context).cardColor,
                    shape: const RoundedRectangleBorder(
                      side: BorderSide.none,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    child: AnimatedContainer(
                      duration: Durations.extralong1,
                      height: showGrafico ? MediaQuery.of(context).size.height * 0.25 : alturaBotaoGrafico,
                      width: MediaQuery.of(context).size.width,
                      onEnd: () {
                        setState(() {
                          animateFinish = true;
                        });
                      },
                      child: Column(
                        children: [
                          //Gráfico
                          if (!showGrafico) const Spacer() else if (animateFinish) grafico else const Spacer(),

                          // Valor e botão de abrir
                          Row(
                            children: [
                              //Espaçador
                              const Spacer(),

                              //Dados do total
                              (config.receitaDespesa) > 0
                                  ? const Icon(
                                      Icons.arrow_upward_rounded,
                                      color: Cores.bom,
                                      size: 12,
                                    )
                                  : const Icon(
                                      Icons.arrow_downward_rounded,
                                      color: Cores.ruim,
                                      size: 12,
                                    ),

                              //Despesa total
                              Text("R\$ ${config.receitaDespesa.toStringAsFixed(2).replaceAll(".", ",")}"),

                              //Espaçador
                              const SizedBox(width: 15),

                              //Botão que fecha ou abre o gráfico
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    showGrafico = !showGrafico;
                                    animateFinish = false;
                                  });
                                },
                                icon: Icon(
                                  showGrafico ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                                ),
                              ),

                              //Espaçador
                              const SizedBox(width: 15),
                            ],
                          ),

                          //Espaçador
                          if (!showGrafico) const Spacer(),
                        ],
                      ),
                    ),
                  ),

                  //Espaçador
                  const SizedBox(height: 15),

                  //Titulo das despesas
                  Row(
                    children: [
                      //Espaçador
                      const SizedBox(width: 15),

                      //Voltar data
                      IconButton(
                        onPressed: () {
                          config.lastMonth().then((value) => setState(() {}));
                        },
                        icon: const Icon(Icons.navigate_before),
                      ),

                      //Spaçador
                      const Spacer(),

                      //Título do mês
                      Builder(
                        builder: (context) {
                          DateTimeRange intervaloDeDatas = config.dateTimeRange;

                          // DataString
                          String formatedString = DateFormat("dd/MMM/yy", 'pt-BR').format(intervaloDeDatas.start);
                          formatedString += " a ";
                          formatedString += DateFormat("dd/MMM/yy", 'pt-BR').format(intervaloDeDatas.end);

                          return MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: TapRegion(
                              child: Text(formatedString.replaceAll(".", "")),
                              onTapInside: (event) async {
                                final DateTime? selected = await showMonthYearPicker(
                                  context: context,
                                  initialDate: config.data,
                                  firstDate: DateTime(1),
                                  lastDate: DateTime(3999),
                                  locale: const Locale.fromSubtags(languageCode: "pt", countryCode: "BR"),
                                );

                                if (selected != null) {
                                  config.setData(DateTime(selected.year, selected.month, Config.diaPagamento)).then((value) {
                                    setState(() {});
                                  });
                                }
                              },
                            ),
                          );
                        },
                      ),

                      //Spaçador
                      const Spacer(),

                      //Avançar as datas
                      IconButton(
                        onPressed: () {
                          config.nextMonth().then((value) => setState(() {}));
                        },
                        icon: const Icon(Icons.navigate_next),
                      ),

                      //Espaçador
                      const SizedBox(width: 15),
                    ],
                  ),

                  //Espaçador
                  const SizedBox(height: 15),

                  //Despesas e receitas
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                      child: ListView.builder(
                        itemCount: lenDespesas + 4,
                        itemBuilder: (context, index) {
                          if (index == lenDespesas + 3) {
                            return const SizedBox(height: 96);
                          }

                          bool ePagamento = false;
                          if (index == 0) {
                            return const Text("Receitas");
                          } else {
                            index -= 1;
                          }

                          if (index == config.receitas.length) {
                            return const Divider();
                          } else if (index == config.receitas.length + 1) {
                            return const Text("Despesas");
                          } else if (index > config.receitas.length) {
                            index = index - config.receitas.length - 2;
                            ePagamento = true;
                          }

                          Despesa despesa = (ePagamento ? config.gastos : config.receitas)[index];

                          return InkWell(
                            onTap: () {
                              changeDispesa(despesa: despesa);
                            },
                            child: Card(
                              child: SizedBox(
                                height: 76,
                                child: Row(
                                  children: [
                                    // Espaçador
                                    const SizedBox(width: 10),

                                    // Despesa paga
                                    InkWell(
                                      child: Icon(
                                        despesa.pago ? Icons.monetization_on : Icons.monetization_on_outlined,
                                        color: despesa.pago ? Cores.bom : null,
                                      ),
                                      onTap: () async {
                                        config
                                            .editDespesa(
                                              id: despesa.id,
                                              parcela: despesa.parcelaAtual,
                                              pago: !despesa.pago,
                                              descricao: despesa.nome,
                                              data: despesa.data,
                                              valor: despesa.valor,
                                              parcelasTotal: despesa.parcelasTotal,
                                              fixo: despesa.fixo,
                                              editAll: false,
                                            )
                                            .then((value) => setState(() {}));
                                      },
                                    ),

                                    //Espaçador
                                    const SizedBox(width: 10),

                                    // Descrição, valor e data
                                    Expanded(
                                      child: Column(
                                        children: [
                                          //Espaçador
                                          const Spacer(),

                                          // Título e valor
                                          Expanded(
                                            child: Row(
                                              children: [
                                                //Título
                                                Expanded(
                                                  child: Text(
                                                    "${despesa.nome}${despesa.parcelasTotal > 0 ? ' - ' : ''}${despesa.parcelasTotal > 0 ? despesa.parcelaAtual : ''}${despesa.parcelasTotal > 0 ? "/${despesa.parcelasTotal}" : ''}",
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),

                                                // Valor
                                                Expanded(
                                                  child: Text(
                                                    "R\$ ${despesa.valor.toStringAsFixed(2).replaceAll(".", ",")}",
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(fontSize: 16, color: despesa.valor < 0 ? Cores.atencao : Cores.bom, overflow: TextOverflow.ellipsis),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          //Subtitulo
                                          Row(
                                            children: [
                                              Text(
                                                DateFormat("dd/MMM", "pt-BR").format(despesa.data),
                                                style: const TextStyle(fontSize: 12),
                                                textAlign: TextAlign.start,
                                              ),
                                              const Spacer(),
                                            ],
                                          ),

                                          //Espaçador
                                          const Spacer(),
                                        ],
                                      ),
                                    ),

                                    //Espaçador
                                    const SizedBox(width: 10),

                                    // Remover a despesa
                                    InkWell(
                                      child: const Icon(
                                        Icons.delete,
                                        size: 22,
                                      ),
                                      onTap: () => Widgets.confimation(context, title: "Deseja realmente excluir ${despesa.nome}", subtitle: "Esta ação é irreversível!").then(
                                        (value) async {
                                          if (value != true) {
                                            return;
                                          }

                                          bool? all = false;
                                          if (despesa.fixo || despesa.parcelasTotal > 0) {
                                            all = await showDialog<bool>(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: const Text("Remover apenas esta ou todos na sequência?"),
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
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        Navigator.of(context).pop(true);
                                                      },
                                                      child: const Text("Remover toda a série"),
                                                    ),

                                                    // Espaçador
                                                    const SizedBox(
                                                      width: 5,
                                                      height: 5,
                                                    ),

                                                    // Alterar somente este mês
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        Navigator.of(context).pop(false);
                                                      },
                                                      child: const Text("Remover apenas este mês"),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          }

                                          if (all != null) {
                                            await config.removeDespesa(
                                              id: despesa.id,
                                              parcela: despesa.parcelaAtual,
                                              removeAll: all,
                                            );
                                          }

                                          setState(() {});
                                        },
                                      ),
                                    ),

                                    //Espaçador
                                    const SizedBox(width: 10),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  //Espaçador
                  const SizedBox(height: 15),
                ],
              ),
            );
          },
        ),

        //Floating button adicionar despesa
        floatingActionButton: FloatingActionButton(
          onPressed: changeDispesa,
          tooltip: 'Adicionar Despesa',
          child: const Icon(
            Icons.point_of_sale,
          ),
        ),
      ),
    );
  }
}

class PhotoHero extends StatelessWidget {
  const PhotoHero({Key? key, required this.photo, required this.onTap, this.width, this.height}) : super(key: key);

  final String photo;
  final VoidCallback onTap;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Hero(
        tag: photo,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Image.asset(
              photo,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
