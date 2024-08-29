import 'package:flutter/material.dart';
import 'package:walletbillow/features/avaliarApp/avaliar_app_config.dart';

Future<bool> avaliarAppPopUp(BuildContext context) async {
  AvaliarAppConfig configuracoes = AvaliarAppConfig();

  bool avaliou = await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Avalie o WB com 5 estrelas!"),
        content: const Text("Me ajude a crescer. Avalie o WB com 5 estrela e deixe um comentário relevante sobre melhorias ou o que você está achando do App!"),
        actions: [
          ElevatedButton(
            onPressed: () {
              configuracoes.onAvaliar();
              Navigator.of(context).pop(true);
            },
            child: const Text("Avaliar o WB"),
          ),
        ],
      );
    },
  );

  if (avaliou == true) {
    return true;
  }
  return false;
}
