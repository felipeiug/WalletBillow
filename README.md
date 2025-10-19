# walletbillow

Aplicativo Flutter simples para controle de receitas, despesas e cartões de crédito.

## Resumo
Gerencia lançamentos (receitas/despesas), cartões de crédito com cores personalizadas e exibe gráficos básicos de balanço mensal.

## Funcionalidades
- Adicionar/editar/remover lançamentos (incluindo parcelados e fixos).
- Gerenciar cartões de crédito e cores.
- Visualização de gráfico linear de gastos/receitas.
- Configurações de fechamento do mês e tema.

## Estrutura principal (lib/)
- main.dart — ponto de entrada.
- core/
  - models/credit_card/credit_card.dart
  - models/lancamentos/lancamento.dart
  - services/credit_card.dart
  - services/gastos/gastos_db.dart
  - services/config_data.dart
  - utils/home_config.dart
- features/
  - home/ (home, change_creditCard.dart, change_despesa.dart)
  - config/config_screen.dart
  - avaliar_app/
- shared/
  - themes/cores.dart
  - widgets/ (color_picker.dart, day_selector.dart, linear_chart.dart, widgets.dart)

## Requisitos
- Flutter SDK (estável)
- Dispositivo/emulador ou navegador (para web)

## Como executar (Windows / terminal)
1. Instalar dependências:
```sh
flutter pub get
```
2. Executar em dispositivo/emulador:
```sh
flutter run
```
3. Executar na web:
```sh
flutter run -d chrome
```

## Build
- Windows: `flutter build windows`
- macOS: `flutter build macos`
- Web: `flutter build web`

## Testes
Executar testes:
```sh
flutter test
```

## Contribuição
- Abrir issues para bugs/feature requests.
- Fork → branch → commit → pull request.
- Seguir padrões existentes do projeto.

## Licença

Este projeto está licenciado sob a MIT License. Substitua "Your Name" e o ano conforme apropriado no texto abaixo ou mantenha o arquivo LICENSE separado na raiz do projeto.

MIT License

Copyright (c) 2025 Your Name

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

// ...existing code...