import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class NumberSlider extends StatefulWidget {
  final int initialValue;
  final ValueChanged<int> onValueChanged;

  const NumberSlider({
    Key? key,
    required this.initialValue,
    required this.onValueChanged,
  }) : super(key: key);

  @override
  State<NumberSlider> createState() => _NumberSliderState();
}

class _NumberSliderState extends State<NumberSlider> {
  late int _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NumberPicker(
          axis: Axis.horizontal,
          minValue: 1,
          maxValue: 15,
          value: _currentValue,
          onChanged: (value) {
            setState(() => _currentValue = value);
            widget.onValueChanged(_currentValue);
          },
        ),
      ],
    );
  }
}
