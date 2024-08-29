import 'package:flutter/material.dart';

class Widgets {
  static Future<bool> confimation(
    BuildContext context, {
    String? title,
    String? subtitle,
  }) async {
    return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: title == null ? null : Text(title),
          content: subtitle == null
              ? null
              : SizedBox(
                  //height: MediaQuery.of(context).size.height * 0.3,
                  child: Text(subtitle),
                ),
          actions: [
            //Botão sim
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Sim"),
            ),

            //Botão não
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Não"),
            ),
          ],
        );
      },
    );
  }
}
