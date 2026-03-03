class AppUtils {
  static String getTime() {
    final now = DateTime.now();
    final hours = now.hour.toString().padLeft(2, '0');
    final minutes = now.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  static String getDate({bool withYear = false}) {
    final now = DateTime.now();
    final days = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    final months = [
      'ene.',
      'feb.',
      'mar.',
      'abr.',
      'may.',
      'jun.',
      'jul.',
      'ago.',
      'set.',
      'oct.',
      'nov.',
      'dic.',
    ];
    final dayName = days[now.weekday - 1];
    final day = now.day.toString().padLeft(2, '0');
    final month = months[now.month - 1];
    final year = now.year.toString();
    if (withYear) {
      return '$dayName, $day $month $year';
    }
    return '$dayName, $day $month';
  }

  static String getDateFromDateTime(
    DateTime dateTime, {
    bool withYear = false,
  }) {
    final days = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    final months = [
      'ene.',
      'feb.',
      'mar.',
      'abr.',
      'may.',
      'jun.',
      'jul.',
      'ago.',
      'set.',
      'oct.',
      'nov.',
      'dic.',
    ];
    final dayName = days[dateTime.weekday - 1];
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = months[dateTime.month - 1];
    final year = dateTime.year.toString();
    if (withYear) {
      return '$dayName, $day $month $year';
    }
    return '$dayName, $day $month';
  }

  static String emojiFeelingAsset(String feeling) {
    switch (feeling.toLowerCase()) {
      case 'alegría':
        return 'assets/alegria.png';
      case 'tristeza':
        return 'assets/triste.png';
      case 'nostalgia':
        return 'assets/nostalgia.png';
      case 'miedo':
        return 'assets/miedo.png';
      case 'enojo':
        return 'assets/enojo.png';
      case 'amor':
        return 'assets/amor.png';
      case 'gratitud':
        return 'assets/gratitud.png';
      case 'esperanza':
        return 'assets/esperanza.png';
      case 'orgullo':
        return 'assets/orgullo.png';
      case 'vergüenza':
        return 'assets/verguenza.png';
      default:
        return '';
    }
  }
}
