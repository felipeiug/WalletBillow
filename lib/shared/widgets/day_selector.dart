import 'package:flutter/material.dart';

class DaySelector extends StatefulWidget {
  const DaySelector({
    super.key,
    this.title,
    this.startValue,
    this.onSelect,
    this.textStyle,
  });

  final String? title;
  final String? startValue;
  final Function(String)? onSelect;
  final TextStyle? textStyle;

  @override
  State<DaySelector> createState() => _DaySelectorState();
}

class _DaySelectorState extends State<DaySelector> {
  String? selectedDay;

  @override
  void initState() {
    selectedDay = widget.startValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (widget.onSelect != null) {
          widget.onSelect!(value);
        }
        setState(() => selectedDay = value);
      },
      itemBuilder: (context) => List.generate(
        29,
        (i) => PopupMenuItem<String>(
          value: (i == 0) ? "Último dia do Mês" : i.toString(),
          textStyle: widget.textStyle,
          child: Text(
            'Dia ${(i == 0) ? "Último dia do Mês" : i}',
          ),
        ),
      ),
      child: Text(
        selectedDay != null ? (selectedDay == 'Último dia do Mês' ? 'Último dia do Mês' : 'Dia ${selectedDay!}') : (widget.title ?? 'Selecione um dia'),
        style: widget.textStyle,
      ),
    );
  }
}
