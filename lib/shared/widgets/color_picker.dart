import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

Future<Color?> showPickerColor(BuildContext context, {Color? initialColor}) async {
  return await showDialog<Color>(
      context: context,
      builder: (context) {
        final Random random = Random();
        Color initColor = initialColor ??
            Color.fromRGBO(
              150 + random.nextInt(106), // R (150-255)
              150 + random.nextInt(106), // G (150-255)
              150 + random.nextInt(106), // B (150-255)
              1.0,
            );

        void onColorChange(color) {
          Navigator.of(context).pop(color);
        }

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Pick a color!'),
              content: SingleChildScrollView(
                // child: ColorPicker(
                // pickerColor: initColor,
                // onColorChanged: (color) {
                //   setState(() {
                //     initialColor = color;
                //   });
                // },

                // Use Material color picker:
                child: MaterialPicker(
                  pickerColor: initColor,
                  onColorChanged: (color) {
                    setState(() {
                      initialColor = color;
                    });
                  },
                ),

                // Use Block color picker:
                // child: BlockPicker(
                // pickerColor: initColor,
                // onColorChanged: (color) {
                //   setState(() {
                //     initialColor = color;
                //   });
                // },
                // ),

                // child: MultipleChoiceBlockPicker(
                // pickerColor: initColor,
                // onColorChanged: (color) {
                //   setState(() {
                //     initialColor = color;
                //   });
                // },
                // ),
              ),
            );
          },
        );
      });
}
