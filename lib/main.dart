import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'temperature_converter.dart';

void main() {
  runApp(const TemperatureApp());
}

class TemperatureApp extends StatelessWidget {
  const TemperatureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Конвертер температури',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1677C8)),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      home: const TemperaturePage(),
    );
  }
}

class TemperaturePage extends StatefulWidget {
  const TemperaturePage({super.key});

  @override
  State<TemperaturePage> createState() => _TemperaturePageState();
}

class _TemperaturePageState extends State<TemperaturePage> {
  final TextEditingController _valueController = TextEditingController();
  TemperatureUnit _from = TemperatureUnit.celsius;
  TemperatureUnit _to = TemperatureUnit.fahrenheit;
  String? _result;
  String? _error;

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  void _convert() {
    final value = double.tryParse(
      _valueController.text.trim().replaceAll(',', '.'),
    );
    if (value == null) {
      setState(() {
        _result = null;
        _error = 'Введіть число, наприклад 12.5.';
      });
      return;
    }

    try {
      final converted = TemperatureConverter.convert(value, _from, _to);
      setState(() {
        _result = '${_formatNumber(converted)} ${_to.symbol}';
        _error = null;
      });
    } on FormatException catch (exception) {
      setState(() {
        _result = null;
        _error = exception.message.toString();
      });
    }
  }

  String _formatNumber(double value) {
    if (value == 0) return '0';
    return value
        .toStringAsPrecision(8)
        .replaceFirst(RegExp(r'\.?0+e'), 'e')
        .replaceFirst(RegExp(r'\.0+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Конвертер температури',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF5F7FB),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                elevation: 1,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 60,
                          height: 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colors.primaryContainer,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(
                            Icons.device_thermostat_rounded,
                            size: 34,
                            color: colors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Оберіть одиниці температури',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Цельсій, Фаренгейт або Кельвін',
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 22),
                      TextField(
                        controller: _valueController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9,.-]'),
                          ),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Значення',
                          hintText: 'Наприклад, 12.5',
                          prefixIcon: const Icon(Icons.thermostat_outlined),
                          suffixText: _from.symbol,
                        ),
                        onSubmitted: (_) => _convert(),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _unitDropdown(
                              label: 'Звідки',
                              selectedUnit: _from,
                              onChanged: (unit) => setState(() {
                                _from = unit;
                                _result = null;
                                _error = null;
                              }),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(Icons.arrow_forward_rounded),
                          ),
                          Expanded(
                            child: _unitDropdown(
                              label: 'Куди',
                              selectedUnit: _to,
                              onChanged: (unit) => setState(() {
                                _to = unit;
                                _result = null;
                                _error = null;
                              }),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      FilledButton.icon(
                        onPressed: _convert,
                        icon: const Icon(Icons.calculate_outlined),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text('Конвертувати'),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        _MessageBox(message: _error!, isError: true),
                      ],
                      if (_result != null) ...[
                        const SizedBox(height: 18),
                        _MessageBox(message: _result!, isError: false),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _unitDropdown({
    required String label,
    required TemperatureUnit selectedUnit,
    required ValueChanged<TemperatureUnit> onChanged,
  }) {
    return DropdownButtonFormField<TemperatureUnit>(
      key: ValueKey<String>(label),
      initialValue: selectedUnit,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: TemperatureUnit.values
          .map(
            (unit) => DropdownMenuItem(
              value: unit,
              child: Text(unit.label, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}

class _MessageBox extends StatelessWidget {
  const _MessageBox({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;
    final background = isError
        ? Theme.of(context).colorScheme.errorContainer
        : Theme.of(context).colorScheme.primaryContainer;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
