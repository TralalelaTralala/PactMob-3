enum TemperatureUnit { celsius, fahrenheit, kelvin }

extension TemperatureUnitDetails on TemperatureUnit {
  String get label => switch (this) {
        TemperatureUnit.celsius => 'Цельсій (°C)',
        TemperatureUnit.fahrenheit => 'Фаренгейт (°F)',
        TemperatureUnit.kelvin => 'Кельвін (K)',
      };

  String get symbol => switch (this) {
        TemperatureUnit.celsius => '°C',
        TemperatureUnit.fahrenheit => '°F',
        TemperatureUnit.kelvin => 'K',
      };
}

class TemperatureConverter {
  const TemperatureConverter._();

  static double convert(
    double value,
    TemperatureUnit from,
    TemperatureUnit to,
  ) {
    final celsius = switch (from) {
      TemperatureUnit.celsius => value,
      TemperatureUnit.fahrenheit => (value - 32) * 5 / 9,
      TemperatureUnit.kelvin => value - 273.15,
    };

    if (celsius < -273.15) {
      throw const FormatException(
        'Температура не може бути нижчою за абсолютний нуль.',
      );
    }

    return switch (to) {
      TemperatureUnit.celsius => celsius,
      TemperatureUnit.fahrenheit => celsius * 9 / 5 + 32,
      TemperatureUnit.kelvin => celsius + 273.15,
    };
  }
}
