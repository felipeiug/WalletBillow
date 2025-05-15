import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:u_credit_card/u_credit_card.dart';
import 'package:walletbillow/core/models/credit_card/credit_card.dart';
import 'package:walletbillow/core/utils/home_config.dart';
import 'package:walletbillow/shared/widgets/color_picker.dart';

class CreditCardScreen extends StatefulWidget {
  final CreditCard? initialCard;
  final HomeUtil config;

  const CreditCardScreen(
    this.config, {
    super.key,
    this.initialCard,
  });

  @override
  State<CreditCardScreen> createState() => _CreditCardState();
}

class _CreditCardState extends State<CreditCardScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeCartaoController;
  late TextEditingController _cardNumberController;
  late TextEditingController _titularController;
  late DateTime _validade;
  late TextEditingController _totalLimitController;
  late bool _noLimit;

  // Estilo do cartão
  late Color cor;

  late bool _vencimentoDiaUtil;
  late int _diaVencimento;
  late bool _melhorDiaParaCompraDiaUtil;
  late int _melhorDiaParaCompra;

  @override
  void initState() {
    super.initState();
    final card = widget.initialCard;
    _nomeCartaoController = TextEditingController(text: card?.nomeCartao ?? '');
    _cardNumberController = TextEditingController(text: card?.cardNumber ?? '');
    _titularController = TextEditingController(text: card?.titular ?? '');
    _validade = card?.validade ?? (DateTime.now().add(Duration(days: (365 * 3))));
    _totalLimitController = TextEditingController(
      text: card != null ? 'R\$${card.totalLimit.toStringAsFixed(2)}' : 'R\$0,00',
    );

    if ((card?.totalLimit ?? 0) < 0) {
      _noLimit = true;
    } else {
      _noLimit = false;
    }

    _vencimentoDiaUtil = card?.vencimentoDiaUtil ?? false;
    _diaVencimento = card?.diaVencimento ?? 15;

    _melhorDiaParaCompraDiaUtil = card?.melhorDiaParaCompraDiaUtil ?? false;
    _melhorDiaParaCompra = card?.melhorDiaParaCompra ?? 5;

    List<int> _cor = card?.cor ?? [255, 128, 59, 179];
    cor = Color.fromARGB(_cor[0], _cor[1], _cor[2], _cor[3]);
  }

  @override
  void dispose() {
    _nomeCartaoController.dispose();
    _cardNumberController.dispose();
    _titularController.dispose();
    _totalLimitController.dispose();
    super.dispose();
  }

  void _formatCurrency() {
    if (_noLimit) {
      _totalLimitController.text = 'R\$-';
      return;
    }

    String text = _totalLimitController.text.replaceAll(RegExp(r'[^0-9]'), '').replaceAll('R\$', '').replaceAll(',', '').replaceAll('.', '');

    if (text.isEmpty) {
      _totalLimitController.text = 'R\$0,00';
      return;
    }

    double value = double.parse(text) / 100;
    _totalLimitController.text = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    ).format(value);

    _totalLimitController.selection = TextSelection.fromPosition(
      TextPosition(offset: _totalLimitController.text.length),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final card = CreditCard(
        id: widget.initialCard?.id,
        nomeCartao: _nomeCartaoController.text,
        cardNumber: _cardNumberController.text,
        titular: _titularController.text,
        validade: _validade,
        totalLimit: _noLimit ? -1 : int.parse(_totalLimitController.text.replaceAll('R\$', '').replaceAll('.', '').replaceAll(',', '')),
        vencimentoDiaUtil: _vencimentoDiaUtil,
        diaVencimento: _diaVencimento,
        melhorDiaParaCompraDiaUtil: _melhorDiaParaCompraDiaUtil,
        melhorDiaParaCompra: _melhorDiaParaCompra,
        cor: [(cor.a * 255).toInt(), (cor.r * 255).toInt(), (cor.g * 255).toInt(), (cor.b * 255).toInt()],
      );

      if (widget.initialCard != null) {
        widget.config.creditCardDB.editCard(
          card.id,
          vencimentoDiaUtil: card.vencimentoDiaUtil,
          diaVencimento: card.diaVencimento,
          melhorDiaParaCompraDiaUtil: card.melhorDiaParaCompraDiaUtil,
          melhorDiaParaCompra: card.melhorDiaParaCompra,
          nomeCartao: card.nomeCartao,
          cardNumber: card.cardNumber,
          titular: card.titular,
          validade: card.validade,
          totalLimit: card.totalLimit,
          cor: card.cor,
        );
      } else {
        widget.config.creditCardDB.addCard(card);
      }

      Navigator.pop<CreditCard>(context, card);
    }
  }

  Future<void> selectMonthYear(BuildContext context) async {
    final DateTime? picked = await showMonthYearPicker(
      context: context,
      initialDate: _validade,
      firstDate: DateTime.now().subtract(Duration(days: 1000 * 365)),
      lastDate: DateTime.now().add(Duration(days: 1000 * 365)),
      initialMonthYearPickerMode: MonthYearPickerMode.year,
    );

    if (picked != null) {
      setState(() {
        _validade = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialCard == null ? 'Novo Cartão' : 'Editar Cartão'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Visualização do cartão
              SizedBox(
                height: 216,
                child: CreditCardUi(
                  cardHolderFullName: _titularController.text,
                  cardNumber: _cardNumberController.text,
                  creditCardType: CreditCard.detectCardType(_cardNumberController.text),
                  validThru: "${_validade.month.toString().padLeft(2, '0')}/${_validade.year.toString().substring(2)}",
                  topLeftColor: cor,
                  bottomRightColor: cor.darken(30),
                  showValidFrom: false,
                  currencySymbol: "R\$",
                  showBalance: true,
                  balance: _totalLimitController.text.contains("-") ? 0.0 : (double.tryParse(_totalLimitController.text.replaceAll(".", "").replaceAll(",", ".").replaceAll("R\$", "")) ?? 0.0),
                ),
              ),

              // Dados básicos do cartão
              _buildSectionTitle('Dados do Cartão'),
              _buildTextFormField(
                controller: _nomeCartaoController,
                label: 'Nome do Cartão',
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                onChange: (value) {
                  setState(() {});
                },
              ),
              _buildTextFormField(
                controller: _cardNumberController,
                label: 'Número do Cartão',
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                onChange: (value) {
                  setState(() {
                    _cardNumberController.text = _cardNumberController.text.replaceAll(RegExp(r'[^0-9]'), '');
                    _cardNumberController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _cardNumberController.text.length),
                    );
                  });
                },
              ),
              _buildTextFormField(
                controller: _titularController,
                label: 'Titular do Cartão',
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                onChange: (value) {
                  setState(() {});
                },
              ),

              // Sem Limite
              SizedBox(
                height: 96,
                child: Row(
                  spacing: 15,
                  children: [
                    Expanded(
                      child: _buildTextFormField(
                        controller: _totalLimitController,
                        label: 'Limite Total',
                        keyboardType: TextInputType.number,
                        onChange: (value) {
                          setState(() {
                            _formatCurrency();
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: 96,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start, // Alinha à esquerda
                        children: [
                          // Texto em cima
                          Text(
                            'Sem Limite',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8), // Espaço entre texto e checkbox

                          // Checkbox embaixo
                          Checkbox(
                            value: _noLimit,
                            onChanged: (bool? value) {
                              setState(() {
                                _noLimit = value ?? false;
                                _formatCurrency();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),

              // Validade
              Row(
                spacing: 15,
                children: [
                  Text("Validade:"),
                  ElevatedButton(
                    onPressed: () => selectMonthYear(context),
                    style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
                    child: Text("${_validade.month.toString().padLeft(2, '0')}/${_validade.year.toString().substring(2)}"),
                  ),
                  Spacer(),
                  const Text("Cor:"),
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
              Divider(),

              // Configuração de vencimento
              _buildSectionTitle('Dia de Vencimento'),
              _buildDaySelector(
                isBusinessDay: _vencimentoDiaUtil,
                day: _diaVencimento,
                onBusinessDayChanged: (value) {
                  setState(() => _vencimentoDiaUtil = value!);
                },
                onDayChanged: (value) {
                  setState(() => _diaVencimento = value);
                },
              ),

              // Melhor dia para compra
              _buildSectionTitle('Melhor Dia para Compra'),
              _buildDaySelector(
                isBusinessDay: _melhorDiaParaCompraDiaUtil,
                day: _melhorDiaParaCompra,
                onBusinessDayChanged: (value) {
                  setState(() => _melhorDiaParaCompraDiaUtil = value!);
                },
                onDayChanged: (value) {
                  setState(() => _melhorDiaParaCompra = value);
                },
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('Salvar Cartão'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    Function(String)? onChange,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: onChange,
        validator: validator,
        keyboardType: keyboardType,
      ),
    );
  }

  Widget _buildDaySelector({
    required bool isBusinessDay,
    required int day,
    required ValueChanged<bool?> onBusinessDayChanged,
    required ValueChanged<int> onDayChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('Dia útil'),
                value: true,
                groupValue: isBusinessDay,
                onChanged: onBusinessDayChanged,
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('Dia fixo'),
                value: false,
                groupValue: isBusinessDay,
                onChanged: onBusinessDayChanged,
              ),
            ),
          ],
        ),
        DropdownButtonFormField<int>(
          value: day,
          items: List.generate(31, (index) => index + 1)
              .map((day) => DropdownMenuItem(
                    value: day,
                    child: Text('Dia $day'),
                  ))
              .toList(),
          onChanged: (value) => onDayChanged(value!),
          decoration: const InputDecoration(
            labelText: 'Dia',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
