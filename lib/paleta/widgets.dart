import 'package:flutter/material.dart';
import 'package:walletbillow/paleta/cores.dart';

class Widgets {
  static Future<bool?> solicitarPro(BuildContext context) async {
    return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Seja pró!"),
          content: const SizedBox(
            //height: MediaQuery.of(context).size.height * 0.3,
            child: Text("Torne-se pró para ter acesso ao app sem anuncios e interrupções"),
          ),
          actions: [
            //Botão cancela
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Cores.ruim),
                padding: MaterialStateProperty.all(EdgeInsets.zero),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Não"),
            ),

            //Botão tornar pró
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Cores.bom),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Seja pró"),
            ),
          ],
        );
      },
    );
  }

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
