import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:walletbillow/core/services/credit_card.dart';

Future<Color?> showPickerColor(BuildContext context, {Color? initialColor}) async {
  return await showDialog<Color>(
      context: context,
      builder: (context) {
        return FutureBuilder(
          future: CreditCardDB.init(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) return Center(child: CircularProgressIndicator());

            CreditCardDB cardDb = snapshot.data!;

            final Random random = Random();
            Color initColor = initialColor ??
                Color.fromRGBO(
                  150 + random.nextInt(106), // R (150-255)
                  150 + random.nextInt(106), // G (150-255)
                  150 + random.nextInt(106), // B (150-255)
                  1.0,
                );

            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: const Text('Selecionar Cor'),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        BlockPicker(
                          pickerColor: initColor,
                          onColorChanged: (color) => Navigator.of(context).pop(color),
                          availableColors: cardDb.creditCardColors,
                        ),
                        Row(
                          children: [
                            Text("Personalizada", style: TextStyle(fontSize: 18)),
                            Spacer(),
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    content: StatefulBuilder(
                                      builder: (context, setState) {
                                        return SingleChildScrollView(
                                          child: ColorPicker(
                                            pickerColor: initColor,
                                            onColorChanged: (color) => setState(() {
                                              initColor = color;
                                            }),
                                          ),
                                        );
                                      },
                                    ),
                                    actions: <Widget>[
                                      ElevatedButton(
                                        child: const Text('Feito'),
                                        onPressed: () {
                                          List<Color> colors = cardDb.creditCardColors;
                                          if (colors.contains(initColor)) return;
                                          colors.add(initColor);
                                          cardDb.creditCardColors = colors;

                                          setState(() {});
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.square,
                                color: initColor,
                                size: 38,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      });
}
