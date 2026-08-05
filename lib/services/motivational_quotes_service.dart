import 'dart:math';

/// Provides motivational quotes for streak and progress screens.
class MotivationalQuotesService {
  MotivationalQuotesService._();
  static final MotivationalQuotesService instance = MotivationalQuotesService._();

  final List<String> _all = [
    // Seguridad digital
    'Las contraseñas son como los cepillos de dientes: no se comparten.',
    'Tu mejor antivirus eres tú mismo.',
    'En la web, la curiosidad mata más que al gato.',
    'No es paranoia si realmente te están rastreando.',
    'La seguridad no es un producto, es un hábito.',
    'Cierra sesión. Siempre.',
    'Las actualizaciones no son opcionales, son tu escudo.',
    'El eslabón más débil en la seguridad siempre es el humano.',
    'No confíes en lo que no pediste.',
    'Tu huella digital dura para siempre.',
    'Un solo clic puede cambiar todo.',
    'La mejor defensa es la prevención.',
    'Piensa antes de hacer clic.',
    'La seguridad empieza contigo.',
    'Navega seguro, vive tranquilo.',
    // Inspiracionales
    'No puedes elegir dónde empieza tu mundo, pero sí dónde termina.',
    'Incluso la antorcha más pequeña ilumina la cueva más grande.',
    'La grandeza nace de pequeños comienzos.',
    'Cuanto más oscura la noche, más brillan las estrellas.',
    'No borres tu mundo por un mal momento.',
    'Hoy seremos mejores.',
    'No sientas la presión. Sé la presión.',
    'Todos fallamos. Lo importante es levantarse.',
    'El que persevera, logra.',
    'Un paso a la vez.',
    'El momento es ahora.',
    'Puedes con esto y con más.',
    'No te rindas, aún no has visto lo que viene.',
    'La disciplina vence a la inteligencia.',
    'El cambio empieza hoy.',
    // Estilo Minecraft
    'Incluso una antorcha puede encender más que tu propio corazón.',
    'Cuantas más encantamientos tiene una herramienta, más duele perderla.',
    'Si el gato quiere ser león, debe renunciar a su apetito por ratones.',
    'No construyas tu casa de madera en un mundo de lava.',
    'Incluso una pico de piedra rompe netherite si le dedicas tiempo.',
    'Cava profundo, encuentra diamantes.',
    'El sol siempre sale después de la tormenta.',
    'Las camas explotan en el nether, pero enseñan a no rendirse.',
    'No temas a la oscuridad, lleva una antorcha.',
    'Los creepers explotan, pero tú te levantas de nuevo.',
    'El agua y la lava juntas crean piedra. Incluso los opuestos construyen.',
    'Las estrellas del fin son infinitas, como tus posibilidades.',
    'Cae del fin, pero siempre vuelves a tu cama.',
    'El dragón no es el fin, es el comienzo de la aventura.',
    'Tus bloques, tu mundo, tus reglas.',
    // Guerrero / disciplina
    'Levántate y lucha como el guerrero que eres.',
    'Un verdadero guerrero nunca abandona el campo de batalla.',
    'La disciplina es el puente entre las metas y los logros.',
    'El dolor es temporal, la gloria es eterna.',
    'Un guerrero no llora por lo perdido, agradece lo que tuvo.',
    'No cuentes los días, haz que los días cuenten.',
    'La suerte es para quienes no se preparan.',
    'El guerrero sabe que la victoria empieza en la mente.',
    'Caer está permitido, levantarse es obligatorio.',
    'El silencio del entrenamiento se escucha en la batalla.',
    'Forja tu carácter antes de que las circunstancias te forjen a ti.',
    'Primero te ignoran, luego se ríen, luego te vencen.',
    'El guerrero más fuerte no es el que siempre gana, sino el que nunca se rinde.',
    'Si Dios está conmigo, ¿quién puede estar contra mí?',
    'Levántate, el mundo aún te espera.',
  ];

  final Set<int> _recent = {};
  int _maxRecent = 8;

  void setMaxRecent(int n) => _maxRecent = n.clamp(2, 20);

  String random() {
    final available = List.generate(_all.length, (i) => i)
      ..removeWhere((i) => _recent.contains(i));

    if (available.isEmpty) {
      _recent.clear();
      return _all[Random().nextInt(_all.length)];
    }

    final idx = available[Random().nextInt(available.length)];
    _recent.add(idx);
    if (_recent.length > _maxRecent) {
      _recent.remove(_recent.first);
    }
    return _all[idx];
  }
}
