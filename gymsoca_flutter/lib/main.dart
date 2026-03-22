import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============= MODELS =============
class User {
  final String name;
  final String email;
  final String objective;
  final String level;
  final double initialWeight;
  final double currentWeight;
  final double bodyFat;
  final double muscleMass;
  final int workouts;
  final List<String> trainedDays;
  final String selectedPlan;
  final List<String> cartItems;
  final List<String> completedExercises;
  final List<String> reservations;
  final int streakDays;
  final int totalMinutes;
  // Onboarding fields
  final int age;
  final double height;
  final String gender;
  final String activityLevel;
  final bool profileComplete;

  User({
    required this.name,
    required this.email,
    required this.objective,
    required this.level,
    required this.initialWeight,
    required this.currentWeight,
    required this.bodyFat,
    required this.muscleMass,
    this.workouts = 0,
    this.trainedDays = const [],
    this.selectedPlan = 'Plan Premium',
    this.cartItems = const [],
    this.completedExercises = const [],
    this.reservations = const [],
    this.streakDays = 0,
    this.totalMinutes = 0,
    this.age = 0,
    this.height = 0,
    this.gender = 'masculino',
    this.activityLevel = 'moderado',
    this.profileComplete = false,
  });

  User copyWith({
    String? name,
    String? email,
    String? objective,
    String? level,
    double? initialWeight,
    double? currentWeight,
    double? bodyFat,
    double? muscleMass,
    int? workouts,
    List<String>? trainedDays,
    String? selectedPlan,
    List<String>? cartItems,
    List<String>? completedExercises,
    List<String>? reservations,
    int? streakDays,
    int? totalMinutes,
    int? age,
    double? height,
    String? gender,
    String? activityLevel,
    bool? profileComplete,
  }) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
      objective: objective ?? this.objective,
      level: level ?? this.level,
      initialWeight: initialWeight ?? this.initialWeight,
      currentWeight: currentWeight ?? this.currentWeight,
      bodyFat: bodyFat ?? this.bodyFat,
      muscleMass: muscleMass ?? this.muscleMass,
      workouts: workouts ?? this.workouts,
      trainedDays: trainedDays ?? this.trainedDays,
      selectedPlan: selectedPlan ?? this.selectedPlan,
      cartItems: cartItems ?? this.cartItems,
      completedExercises: completedExercises ?? this.completedExercises,
      reservations: reservations ?? this.reservations,
      streakDays: streakDays ?? this.streakDays,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      age: age ?? this.age,
      height: height ?? this.height,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      profileComplete: profileComplete ?? this.profileComplete,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'objective': objective,
    'level': level,
    'initialWeight': initialWeight,
    'currentWeight': currentWeight,
    'bodyFat': bodyFat,
    'muscleMass': muscleMass,
    'workouts': workouts,
    'trainedDays': trainedDays,
    'selectedPlan': selectedPlan,
    'cartItems': cartItems,
    'completedExercises': completedExercises,
    'reservations': reservations,
    'streakDays': streakDays,
    'totalMinutes': totalMinutes,
    'age': age,
    'height': height,
    'gender': gender,
    'activityLevel': activityLevel,
    'profileComplete': profileComplete,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    objective: json['objective'] ?? 'musculo',
    level: json['level'] ?? 'principiante',
    initialWeight: (json['initialWeight'] ?? 0.0).toDouble(),
    currentWeight: (json['currentWeight'] ?? 0.0).toDouble(),
    bodyFat: (json['bodyFat'] ?? 0.0).toDouble(),
    muscleMass: (json['muscleMass'] ?? 0.0).toDouble(),
    workouts: json['workouts'] ?? 0,
    trainedDays: List<String>.from(json['trainedDays'] ?? []),
    selectedPlan: json['selectedPlan'] ?? 'Plan Premium',
    cartItems: List<String>.from(json['cartItems'] ?? []),
    completedExercises: List<String>.from(json['completedExercises'] ?? []),
    reservations: List<String>.from(json['reservations'] ?? []),
    streakDays: json['streakDays'] ?? 0,
    totalMinutes: json['totalMinutes'] ?? 0,
    age: json['age'] ?? 0,
    height: (json['height'] ?? 0.0).toDouble(),
    gender: json['gender'] ?? 'masculino',
    activityLevel: json['activityLevel'] ?? 'moderado',
    profileComplete: json['profileComplete'] ?? false,
  );

  // ============= CALCULATED PROPERTIES =============
  double get bmi => (height > 0 && currentWeight > 0)
      ? currentWeight / ((height / 100) * (height / 100))
      : 0;

  String get bmiCategory {
    if (bmi == 0) return '-';
    if (bmi < 18.5) return 'Bajo peso';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Sobrepeso';
    return 'Obesidad';
  }

  // Mifflin-St Jeor
  double get bmr {
    if (currentWeight == 0 || height == 0 || age == 0) return 0;
    if (gender == 'masculino') {
      return (10 * currentWeight) + (6.25 * height) - (5 * age) + 5;
    } else {
      return (10 * currentWeight) + (6.25 * height) - (5 * age) - 161;
    }
  }

  double get tdee {
    const factors = {
      'sedentario': 1.2,
      'ligero': 1.375,
      'moderado': 1.55,
      'activo': 1.725,
      'muy_activo': 1.9,
    };
    return bmr * (factors[activityLevel] ?? 1.55);
  }

  double get dailyCalories => objective == 'musculo' ? tdee + 300 : tdee - 400;

  double get dailyProtein => currentWeight > 0
      ? currentWeight * (objective == 'musculo' ? 2.0 : 1.8)
      : 0;

  double get dailyCarbs =>
      ((dailyCalories - (dailyProtein * 4) - (currentWeight * 0.9 * 9)) / 4)
          .clamp(50, 600);
}

class Exercise {
  final String id;
  final String name;
  final String muscleGroup;
  final String reps;
  final int series;
  final String? imagePath;
  final String tip;

  const Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.reps,
    required this.series,
    this.imagePath,
    this.tip = '',
  });
}

class WorkoutDay {
  final String day;
  final String focus;
  final List<Exercise> exercises;

  const WorkoutDay({
    required this.day,
    required this.focus,
    required this.exercises,
  });
}

class Product {
  final String id;
  final String name;
  final String category;
  final int price;
  final String? imagePath;
  final Color color;
  final String description;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.imagePath,
    required this.color,
    this.description = '',
  });
}

class GymClass {
  final String name;
  final String instructor;
  final String time;
  final String duration;
  final String day;
  final String? imagePath;
  final int spots;

  const GymClass({
    required this.name,
    required this.instructor,
    required this.time,
    required this.duration,
    required this.day,
    this.imagePath,
    required this.spots,
  });
}

// ============= DATA =============
class GymData {
  static const List<WorkoutDay> workoutPlan = [
    WorkoutDay(
      day: 'Lunes',
      focus: 'Pecho & Tríceps',
      exercises: [
        Exercise(
          id: 'e1',
          name: 'Press de Banca con Barra',
          muscleGroup: 'Pecho',
          reps: '8-12',
          series: 4,
          imagePath: 'assets/img/presinclinadobarra.webp',
          tip: 'Mantén los pies en el suelo y la espalda en la banca.',
        ),
        Exercise(
          id: 'e2',
          name: 'Press Inclinado con Mancuernas',
          muscleGroup: 'Pecho Superior',
          reps: '10-12',
          series: 3,
          imagePath: 'assets/img/presinclinadobarra.webp',
          tip: 'Ángulo de 30-45° para mayor activación del pecho superior.',
        ),
        Exercise(
          id: 'e3',
          name: 'Fondos en Paralelas',
          muscleGroup: 'Tríceps / Pecho',
          reps: '10-15',
          series: 3,
          imagePath: 'assets/img/sentadillabarra.avif',
          tip: 'Inclínate hacia adelante para mayor trabajo de pecho.',
        ),
        Exercise(
          id: 'e4',
          name: 'Extensiones de Tríceps en Polea',
          muscleGroup: 'Tríceps',
          reps: '12-15',
          series: 3,
          imagePath: 'assets/img/sentadillabarra.avif',
          tip: 'Mantén los codos pegados al cuerpo durante el movimiento.',
        ),
      ],
    ),
    WorkoutDay(
      day: 'Martes',
      focus: 'Espalda & Bíceps',
      exercises: [
        Exercise(
          id: 'e5',
          name: 'Peso Muerto con Barra',
          muscleGroup: 'Espalda Baja / Glúteos',
          reps: '5-8',
          series: 4,
          imagePath: 'assets/img/pesomuertobarra.webp',
          tip: 'Espalda recta y barra cerca del cuerpo en todo momento.',
        ),
        Exercise(
          id: 'e6',
          name: 'Jalón al Pecho en Polea',
          muscleGroup: 'Dorsal',
          reps: '10-12',
          series: 4,
          imagePath: 'assets/img/sentadillabarra.avif',
          tip: 'Lleva el pecho al agarre, no solo bajes los brazos.',
        ),
        Exercise(
          id: 'e7',
          name: 'Remo con Barra',
          muscleGroup: 'Espalda Media',
          reps: '8-12',
          series: 3,
          imagePath: 'assets/img/pesomuertobarra.webp',
          tip: 'Torso a 45°, lleva la barra al ombligo.',
        ),
        Exercise(
          id: 'e8',
          name: 'Curl de Bíceps con Barra',
          muscleGroup: 'Bíceps',
          reps: '10-12',
          series: 3,
          imagePath: 'assets/img/sentadillabarra.avif',
          tip: 'No balancees el cuerpo, contrae en la cima del movimiento.',
        ),
      ],
    ),
    WorkoutDay(
      day: 'Miércoles',
      focus: 'Piernas',
      exercises: [
        Exercise(
          id: 'e9',
          name: 'Sentadilla con Barra',
          muscleGroup: 'Cuádriceps / Glúteos',
          reps: '6-10',
          series: 4,
          imagePath: 'assets/img/sentadillabarra.avif',
          tip:
              'Rodillas alineadas con los pies, profundidad paralela al suelo.',
        ),
        Exercise(
          id: 'e10',
          name: 'Prensa de Piernas',
          muscleGroup: 'Cuádriceps',
          reps: '10-15',
          series: 3,
          imagePath: 'assets/img/sentadillabarra.avif',
          tip: 'No bloquees las rodillas al extender.',
        ),
        Exercise(
          id: 'e11',
          name: 'Curl de Femoral en Máquina',
          muscleGroup: 'Isquiotibiales',
          reps: '12-15',
          series: 3,
          imagePath: 'assets/img/sentadillabarra.avif',
          tip: 'Contrae fuerte en la cima del movimiento.',
        ),
        Exercise(
          id: 'e12',
          name: 'Elevación de Gemelos de Pie',
          muscleGroup: 'Gemelos',
          reps: '15-20',
          series: 4,
          imagePath: 'assets/img/sentadillabarra.avif',
          tip:
              'Pausa de 1 segundo arriba y abajo para mejor rango de movimiento.',
        ),
      ],
    ),
    WorkoutDay(
      day: 'Jueves',
      focus: 'Hombros & Abdomen',
      exercises: [
        Exercise(
          id: 'e13',
          name: 'Press Militar con Barra',
          muscleGroup: 'Hombros',
          reps: '8-10',
          series: 4,
          imagePath: 'assets/img/presinclinadobarra.webp',
          tip: 'No arquees la zona lumbar al empujar.',
        ),
        Exercise(
          id: 'e14',
          name: 'Elevaciones Laterales con Mancuernas',
          muscleGroup: 'Deltoides Lateral',
          reps: '12-15',
          series: 3,
          imagePath: 'assets/img/presinclinadobarra.webp',
          tip:
              'Codos ligeramente doblados, no subes por encima de los hombros.',
        ),
        Exercise(
          id: 'e15',
          name: 'Plancha Abdominal',
          muscleGroup: 'Core',
          reps: '45-60 seg',
          series: 3,
          imagePath: 'assets/img/sentadillabarra.avif',
          tip: 'Cuerpo recto como una tabla, activa el abdomen.',
        ),
        Exercise(
          id: 'e16',
          name: 'Abdominales en Polea',
          muscleGroup: 'Abdomen',
          reps: '15-20',
          series: 3,
          imagePath: 'assets/img/sentadillabarra.avif',
          tip: 'Contrae el abdomen llevando el pecho hacia las rodillas.',
        ),
      ],
    ),
    WorkoutDay(
      day: 'Viernes',
      focus: 'Full Body Fuerza',
      exercises: [
        Exercise(
          id: 'e17',
          name: 'Sentadilla Frontal',
          muscleGroup: 'Cuádriceps / Core',
          reps: '5-8',
          series: 4,
          imagePath: 'assets/img/sentadillabarra.avif',
          tip: 'Codos arriba y torso erguido en todo momento.',
        ),
        Exercise(
          id: 'e18',
          name: 'Press de Banca Inclinado',
          muscleGroup: 'Pecho Superior',
          reps: '8-10',
          series: 3,
          imagePath: 'assets/img/presinclinadobarra.webp',
          tip: 'Bajada controlada 2 segundos, explosivo al subir.',
        ),
        Exercise(
          id: 'e19',
          name: 'Dominadas con Lastre',
          muscleGroup: 'Dorsal / Bíceps',
          reps: '5-8',
          series: 3,
          imagePath: 'assets/img/sentadillabarra.avif',
          tip: 'Pecho al agarre, escápulas hacia atrás y abajo.',
        ),
        Exercise(
          id: 'e20',
          name: 'Hip Thrust con Barra',
          muscleGroup: 'Glúteos',
          reps: '10-12',
          series: 4,
          imagePath: 'assets/img/sentadillabarra.avif',
          tip: 'Apóyate en el borde de la banca a la altura del omóplato.',
        ),
      ],
    ),
    WorkoutDay(
      day: 'Sábado',
      focus: 'Cardio & Movilidad',
      exercises: [
        Exercise(
          id: 'e21',
          name: 'Cardio en Cinta (HIIT)',
          muscleGroup: 'Cardiovascular',
          reps: '20 min',
          series: 1,
          imagePath: 'assets/img/sentadillabarra.avif',
          tip: '30 seg sprint / 90 seg caminata, 8 rondas.',
        ),
        Exercise(
          id: 'e22',
          name: 'Estiramiento de Cadera',
          muscleGroup: 'Movilidad',
          reps: '30 seg c/lado',
          series: 3,
          imagePath: 'assets/img/sentadillabarra.avif',
          tip: 'Fundamental para prevenir lesiones en piernas.',
        ),
        Exercise(
          id: 'e23',
          name: 'Rodillo de Espuma (Foam Roller)',
          muscleGroup: 'Recuperación',
          reps: '60 seg/zona',
          series: 1,
          imagePath: 'assets/img/sentadillabarra.avif',
          tip: 'Trabaja cuádriceps, isquios, y espalda baja.',
        ),
        Exercise(
          id: 'e24',
          name: 'Yoga de Recuperación',
          muscleGroup: 'Cuerpo Completo',
          reps: '15 min',
          series: 1,
          imagePath: 'assets/img/sentadillabarra.avif',
          tip: 'Enfócate en la respiración y en soltar la tensión.',
        ),
      ],
    ),
  ];

  static const List<Product> products = [
    Product(
      id: 'p1',
      name: 'Proteína Whey 2kg',
      category: 'suplementos',
      price: 85000,
      imagePath: 'assets/img/suplementos/batidosproteina.jpg',
      color: Color(0xFF4CAF50),
      description:
          'Proteína de suero de alta calidad. 25g de proteína por porción.',
    ),
    Product(
      id: 'p2',
      name: 'Creatina 500g',
      category: 'suplementos',
      price: 45000,
      imagePath: 'assets/img/suplementos/proteinaporscoop.jpg',
      color: Color(0xFFFF9800),
      description:
          'Monohidrato de creatina puro para aumentar fuerza y masa muscular.',
    ),
    Product(
      id: 'p3',
      name: 'Pre-Entreno (30 serv)',
      category: 'suplementos',
      price: 60000,
      imagePath: 'assets/img/bebidas/bebidaenergetica.jpg',
      color: Color(0xFFE10600),
      description:
          'Máxima energía y enfoque para tus entrenamientos más intensos.',
    ),
    Product(
      id: 'p4',
      name: 'Barritas de Proteína x12',
      category: 'suplementos',
      price: 35000,
      imagePath: 'assets/img/suplementos/barritasproteicas.jpg',
      color: Color(0xFF9C27B0),
      description: '20g de proteína por barrita. Snack ideal post-entreno.',
    ),
    Product(
      id: 'p5',
      name: 'Guantes de Levantamiento',
      category: 'accesorios',
      price: 35000,
      imagePath: 'assets/img/equipamiento/guantes.jpg',
      color: Color(0xFF2196F3),
      description:
          'Protege tus manos y mejora el agarre en todos los ejercicios.',
    ),
    Product(
      id: 'p6',
      name: 'Cinturón de Levantamiento',
      category: 'accesorios',
      price: 75000,
      imagePath: 'assets/img/equipamiento/cinturondelevantamiento.jpg',
      color: Color(0xFF795548),
      description: 'Soporte lumbar profesional para levantamientos pesados.',
    ),
    Product(
      id: 'p7',
      name: 'Rodilleras Compresivas',
      category: 'accesorios',
      price: 40000,
      imagePath: 'assets/img/equipamiento/rodilleras.jpg',
      color: Color(0xFF607D8B),
      description: 'Estabilidad y compresión para sentadillas y prensa.',
    ),
    Product(
      id: 'p8',
      name: 'Botella 1L Gym Soca',
      category: 'accesorios',
      price: 25000,
      imagePath: 'assets/img/bebidas/aguaalcalina.jpg',
      color: Color(0xFFE10600),
      description: 'Botella deportiva con logo oficial de Gym Soca.',
    ),
    Product(
      id: 'p9',
      name: 'Straps de Levantamiento',
      category: 'accesorios',
      price: 30000,
      imagePath: 'assets/img/equipamiento/straps.jpg',
      color: Color(0xFF212121),
      description:
          'Correas de agarre para mejorar tracción en espalda y peso muerto.',
    ),
    Product(
      id: 'p10',
      name: 'Bandas Elásticas Pro',
      category: 'accesorios',
      price: 28000,
      imagePath: 'assets/img/equipamiento/bandaselasticas.jpg',
      color: Color(0xFF37474F),
      description:
          'Set de bandas para activación, movilidad y trabajo de glúteos.',
    ),
    Product(
      id: 'p11',
      name: 'Cuerda para Saltar Speed',
      category: 'accesorios',
      price: 22000,
      imagePath: 'assets/img/equipamiento/cuerdasaltar.jpg',
      color: Color(0xFF26A69A),
      description: 'Ideal para cardio, calentamiento y coordinación.',
    ),
    Product(
      id: 'p12',
      name: 'Foam Roller Recovery',
      category: 'accesorios',
      price: 27000,
      imagePath: 'assets/img/equipamiento/froamroller.jpg',
      color: Color(0xFF7E57C2),
      description:
          'Rodillo de masaje para liberar tensión muscular post-entreno.',
    ),
    Product(
      id: 'p13',
      name: 'Muñequeras de Soporte',
      category: 'accesorios',
      price: 26000,
      imagePath: 'assets/img/equipamiento/muñequeras.jpg',
      color: Color(0xFF5C6BC0),
      description: 'Mayor estabilidad para press y trabajo de empuje.',
    ),
    Product(
      id: 'p14',
      name: 'Shaker Mezclador 700ml',
      category: 'accesorios',
      price: 18000,
      imagePath: 'assets/img/equipamiento/shaker.jpg',
      color: Color(0xFF29B6F6),
      description: 'Lleva tus batidos y suplementos a cualquier parte.',
    ),
    Product(
      id: 'p15',
      name: 'Proteína Classic 1kg',
      category: 'suplementos',
      price: 65000,
      imagePath: 'assets/img/proteina.jpg',
      color: Color(0xFF66BB6A),
      description: 'Formato práctico para complementar proteína diaria.',
    ),
    Product(
      id: 'p16',
      name: 'Camiseta Dry-Fit Hombre',
      category: 'ropa',
      price: 32000,
      imagePath: 'assets/img/hombrecambio.jpg',
      color: Color(0xFF263238),
      description: 'Tela transpirable y ajuste cómodo para entrenar.',
    ),
    Product(
      id: 'p17',
      name: 'Top Deportivo Mujer',
      category: 'ropa',
      price: 29000,
      imagePath: 'assets/img/mujercambio.jpeg',
      color: Color(0xFF455A64),
      description:
          'Soporte ligero y comodidad para sesiones de alta intensidad.',
    ),
  ];

  static const List<GymClass> classes = [
    GymClass(
      name: 'Hipertrofia Avanzada',
      instructor: 'Brayan Carrillo',
      time: '07:00 AM',
      duration: '60 min',
      day: 'Lunes',
      imagePath: 'assets/img/imagenesdelgym/gymprincipal1.png',
      spots: 10,
    ),
    GymClass(
      name: 'Fuerza & Potencia',
      instructor: 'Brayan Carrillo',
      time: '06:00 AM',
      duration: '75 min',
      day: 'Martes',
      imagePath: 'assets/img/imagenesdelgym/gymprincipal2.png',
      spots: 8,
    ),
    GymClass(
      name: 'Piernas Explosivas',
      instructor: 'Brayan Carrillo',
      time: '07:00 AM',
      duration: '60 min',
      day: 'Miércoles',
      imagePath: 'assets/img/imagenesdelgym/gymprincipal3.png',
      spots: 12,
    ),
    GymClass(
      name: 'Cardio HIIT',
      instructor: 'Brayan Carrillo',
      time: '06:30 AM',
      duration: '45 min',
      day: 'Jueves',
      imagePath: 'assets/img/imagenesdelgym/gymprincipla4.png',
      spots: 15,
    ),
    GymClass(
      name: 'Full Body Intenso',
      instructor: 'Brayan Carrillo',
      time: '07:00 AM',
      duration: '60 min',
      day: 'Viernes',
      imagePath: 'assets/img/brayancarrillo.jpg',
      spots: 10,
    ),
    GymClass(
      name: 'Yoga & Movilidad',
      instructor: 'Brayan Carrillo',
      time: '09:00 AM',
      duration: '60 min',
      day: 'Sábado',
      imagePath: 'assets/img/mujercambio.jpeg',
      spots: 20,
    ),
  ];
}

// ============= THEME =============
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF090909),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFE10600),
        secondary: Color(0xFFE10600),
        surface: Color(0xFF141414),
        error: Color(0xFFFF5252),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF141414),
        foregroundColor: Color(0xFFFFFFFF),
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF141414),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE10600),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE10600), width: 2),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
      ),
    );
  }
}

// ============= PROVIDERS =============
final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<User?> {
  AuthNotifier() : super(null) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('gym_soca_user');
    if (json != null) {
      state = User.fromJson(jsonDecode(json));
    }
  }

  Future<void> login(
    String name,
    String email,
    String objective,
    String level,
  ) async {
    final user = User(
      name: name,
      email: email,
      objective: objective,
      level: level,
      initialWeight: 0,
      currentWeight: 0,
      bodyFat: 0,
      muscleMass: 0,
      profileComplete: false,
    );
    state = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gym_soca_user', jsonEncode(user.toJson()));
  }

  Future<void> completeOnboarding({
    required double weight,
    required double height,
    required int age,
    required String gender,
    required String activityLevel,
  }) async {
    if (state == null) return;
    // Estimaciones iniciales de composición corporal
    final bmi = weight / ((height / 100) * (height / 100));
    double bodyFat;
    if (gender == 'masculino') {
      bodyFat = (1.20 * bmi + 0.23 * age - 16.2).clamp(5.0, 50.0);
    } else {
      bodyFat = (1.20 * bmi + 0.23 * age - 5.4).clamp(10.0, 60.0);
    }
    final muscleMass = (weight * (1 - bodyFat / 100) * 0.5).clamp(10.0, 80.0);

    final updated = state!.copyWith(
      initialWeight: weight,
      currentWeight: weight,
      bodyFat: bodyFat,
      muscleMass: muscleMass,
      height: height,
      age: age,
      gender: gender,
      activityLevel: activityLevel,
      profileComplete: true,
    );
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gym_soca_user', jsonEncode(updated.toJson()));
  }

  Future<void> logout() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('gym_soca_user');
  }

  Future<void> completeExercise(String exerciseId) async {
    if (state == null) return;
    final completed = [...state!.completedExercises];
    if (!completed.contains(exerciseId)) {
      completed.add(exerciseId);
      final updated = state!.copyWith(
        completedExercises: completed,
        workouts: state!.workouts + 1,
        totalMinutes: state!.totalMinutes + 5,
        streakDays: state!.streakDays + 1,
      );
      state = updated;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('gym_soca_user', jsonEncode(updated.toJson()));
    }
  }

  Future<void> toggleReservation(String classKey) async {
    if (state == null) return;
    final reservations = [...state!.reservations];
    if (reservations.contains(classKey)) {
      reservations.remove(classKey);
    } else {
      reservations.add(classKey);
    }
    final updated = state!.copyWith(reservations: reservations);
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gym_soca_user', jsonEncode(updated.toJson()));
  }

  Future<void> addToCart(String productId) async {
    if (state == null) return;
    final cart = [...state!.cartItems, productId];
    final updated = state!.copyWith(cartItems: cart);
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gym_soca_user', jsonEncode(updated.toJson()));
  }

  Future<void> removeFromCart(String productId) async {
    if (state == null) return;
    final cart = [...state!.cartItems];
    cart.remove(productId);
    final updated = state!.copyWith(cartItems: cart);
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gym_soca_user', jsonEncode(updated.toJson()));
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final user = ref.watch(authProvider);

  return GoRouter(
    initialLocation: user != null ? '/home' : '/login',
    redirect: (context, state) {
      final loc = state.matchedLocation;
      if (user == null) {
        return loc != '/login' ? '/login' : null;
      }
      if (!user.profileComplete) {
        return loc != '/onboarding' ? '/onboarding' : null;
      }
      if (loc == '/login' || loc == '/onboarding') {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/workouts', builder: (_, __) => const WorkoutScreen()),
          GoRoute(path: '/store', builder: (_, __) => const StoreScreen()),
          GoRoute(
            path: '/reservations',
            builder: (_, __) => const ReservationsScreen(),
          ),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
    ],
  );
});

// ============= SCREENS =============
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  String objective = 'musculo';
  String level = 'principiante';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 60),
            Text(
              'GYM SOCA',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: const Color(0xFFE10600),
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/img/gymsoca.jpg',
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 40),
            TextFormField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: passCtrl,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField(
              initialValue: objective,
              items: const [
                DropdownMenuItem(
                  value: 'musculo',
                  child: Text('Ganar Músculo'),
                ),
                DropdownMenuItem(value: 'grasa', child: Text('Perder Grasa')),
              ],
              onChanged: (val) => setState(() => objective = val ?? 'musculo'),
              decoration: const InputDecoration(labelText: 'Objetivo'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField(
              initialValue: level,
              items: const [
                DropdownMenuItem(
                  value: 'principiante',
                  child: Text('Principiante'),
                ),
                DropdownMenuItem(value: 'avanzado', child: Text('Avanzado')),
              ],
              onChanged: (val) => setState(() => level = val ?? 'principiante'),
              decoration: const InputDecoration(labelText: 'Nivel'),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  final navigator = GoRouter.of(context);
                  await ref
                      .read(authProvider.notifier)
                      .login(nameCtrl.text, emailCtrl.text, objective, level);
                  if (!mounted) return;
                  navigator.go('/home');
                },
                child: const Text('Iniciar Sesión'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============= ONBOARDING =============
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  // Form values
  String _gender = 'masculino';
  double _age = 25;
  double _height = 170;
  double _weight = 70;
  String _activity = 'moderado';

  // Calculated results (shown on final page)
  double _bmi = 0;
  double _bmr = 0;
  double _tdee = 0;
  double _kcal = 0;
  double _protein = 0;

  static const _activities = [
    {
      'key': 'sedentario',
      'label': 'Sedentario',
      'desc': 'Sin ejercicio o muy poco',
      'icon': Icons.weekend,
    },
    {
      'key': 'ligero',
      'label': 'Ligero',
      'desc': '1-3 días por semana',
      'icon': Icons.directions_walk,
    },
    {
      'key': 'moderado',
      'label': 'Moderado',
      'desc': '3-5 días por semana',
      'icon': Icons.directions_bike,
    },
    {
      'key': 'activo',
      'label': 'Activo',
      'desc': '6-7 días por semana',
      'icon': Icons.fitness_center,
    },
    {
      'key': 'muy_activo',
      'label': 'Muy Activo',
      'desc': 'Doble sesión diaria',
      'icon': Icons.flash_on,
    },
  ];

  void _calcResults(String objective) {
    final h = _height;
    final w = _weight;
    final a = _age.round();
    _bmi = w / ((h / 100) * (h / 100));
    _bmr = _gender == 'masculino'
        ? (10 * w) + (6.25 * h) - (5 * a) + 5
        : (10 * w) + (6.25 * h) - (5 * a) - 161;
    const factors = {
      'sedentario': 1.2,
      'ligero': 1.375,
      'moderado': 1.55,
      'activo': 1.725,
      'muy_activo': 1.9,
    };
    _tdee = _bmr * (factors[_activity] ?? 1.55);
    _kcal = objective == 'musculo' ? _tdee + 300 : _tdee - 400;
    _protein = w * (objective == 'musculo' ? 2.0 : 1.8);
  }

  void _goNext() {
    if (_currentPage < 4) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage++);
    } else {
      _finish();
    }
  }

  void _goPrev() {
    if (_currentPage > 0) {
      _pageCtrl.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage--);
    }
  }

  Future<void> _finish() async {
    await ref
        .read(authProvider.notifier)
        .completeOnboarding(
          weight: _weight,
          height: _height,
          age: _age.round(),
          gender: _gender,
          activityLevel: _activity,
        );
    if (!mounted) return;
    GoRouter.of(context).go('/home');
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  String get _bmiCategory {
    if (_bmi < 18.5) return 'Bajo peso';
    if (_bmi < 25) return 'Normal ✓';
    if (_bmi < 30) return 'Sobrepeso';
    return 'Obesidad';
  }

  Color get _bmiColor {
    if (_bmi < 18.5) return Colors.blue;
    if (_bmi < 25) return const Color(0xFF4CAF50);
    if (_bmi < 30) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final objective = user?.objective ?? 'musculo';

    if (_currentPage == 4) _calcResults(objective);

    return Scaffold(
      backgroundColor: const Color(0xFF090909),
      body: SafeArea(
        child: Column(
          children: [
            // Header & progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (_currentPage > 0)
                        GestureDetector(
                          onTap: _goPrev,
                          child: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ),
                      const Spacer(),
                      Text(
                        '${_currentPage + 1} / 5',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_currentPage + 1) / 5,
                      minHeight: 5,
                      backgroundColor: const Color(0xFF1E1E1E),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFE10600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Pages
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _GenderPage(
                    selected: _gender,
                    onChanged: (v) => setState(() => _gender = v),
                  ),
                  _SliderPage(
                    title: '¿Cuántos años tenés?',
                    icon: Icons.cake,
                    value: _age,
                    min: 14,
                    max: 80,
                    divisions: 66,
                    unit: 'años',
                    onChanged: (v) => setState(() => _age = v),
                  ),
                  _SliderPage(
                    title: '¿Cuánto medís?',
                    icon: Icons.height,
                    value: _height,
                    min: 140,
                    max: 220,
                    divisions: 80,
                    unit: 'cm',
                    onChanged: (v) => setState(() => _height = v),
                  ),
                  _SliderPage(
                    title: '¿Cuánto pesás?',
                    icon: Icons.monitor_weight,
                    value: _weight,
                    min: 40,
                    max: 180,
                    divisions: 140,
                    unit: 'kg',
                    onChanged: (v) => setState(() => _weight = v),
                  ),
                  _ActivityPage(
                    selected: _activity,
                    activities: _activities,
                    onChanged: (v) => setState(() => _activity = v),
                  ),
                ],
              ),
            ),
            // Results preview on last page
            if (_currentPage == 4)
              _ResultsPreview(
                bmi: _bmi,
                bmiCategory: _bmiCategory,
                bmiColor: _bmiColor,
                bmr: _bmr,
                tdee: _tdee,
                kcal: _kcal,
                protein: _protein,
              ),
            // Bottom CTA
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _goNext,
                  child: Text(
                    _currentPage < 4 ? 'Continuar' : '¡Comenzar mi plan! 🚀',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderPage extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _GenderPage({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿Cuál es tu género?',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Necesitamos esto para calcular tu metabolismo basal con precisión.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              _GenderCard(
                label: 'Masculino',
                icon: Icons.male,
                isSelected: selected == 'masculino',
                onTap: () => onChanged('masculino'),
              ),
              const SizedBox(width: 16),
              _GenderCard(
                label: 'Femenino',
                icon: Icons.female,
                isSelected: selected == 'femenino',
                onTap: () => onChanged('femenino'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  const _GenderCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 140,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFE10600).withValues(alpha: 0.15)
                : const Color(0xFF141414),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFFE10600) : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 50,
                color: isSelected ? const Color(0xFFE10600) : Colors.grey,
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isSelected ? const Color(0xFFE10600) : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliderPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final double value;
  final double min, max;
  final int divisions;
  final String unit;
  final ValueChanged<double> onChanged;

  const _SliderPage({
    required this.title,
    required this.icon,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.unit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Deslizá para ajustar el valor.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const Spacer(),
          Center(
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE10600), width: 2),
              ),
              child: Column(
                children: [
                  Icon(icon, color: const Color(0xFFE10600), size: 32),
                  const SizedBox(height: 8),
                  Text(
                    unit == 'años'
                        ? '${value.round()}'
                        : value.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    unit,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFFE10600),
              thumbColor: const Color(0xFFE10600),
              inactiveTrackColor: const Color(0xFF1E1E1E),
              overlayColor: const Color(0xFFE10600).withValues(alpha: 0.2),
              trackHeight: 6,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${min.round()} $unit',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                '${max.round()} $unit',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _ActivityPage extends StatelessWidget {
  final String selected;
  final List<Map<String, dynamic>> activities;
  final ValueChanged<String> onChanged;
  const _ActivityPage({
    required this.selected,
    required this.activities,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nivel de actividad física',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '¿Cuánto te movés en promedio por semana?',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: activities.map((a) {
                final isSelected = selected == a['key'];
                return GestureDetector(
                  onTap: () => onChanged(a['key'] as String),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFE10600).withValues(alpha: 0.12)
                          : const Color(0xFF141414),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFE10600)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFE10600).withValues(alpha: 0.2)
                                : const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            a['icon'] as IconData,
                            color: isSelected
                                ? const Color(0xFFE10600)
                                : Colors.grey,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                a['label'] as String,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? const Color(0xFFE10600)
                                      : Colors.white,
                                ),
                              ),
                              Text(
                                a['desc'] as String,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFFE10600),
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultsPreview extends StatelessWidget {
  final double bmi, bmr, tdee, kcal, protein;
  final String bmiCategory;
  final Color bmiColor;
  const _ResultsPreview({
    required this.bmi,
    required this.bmiCategory,
    required this.bmiColor,
    required this.bmr,
    required this.tdee,
    required this.kcal,
    required this.protein,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE10600).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Tus resultados',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _ResultChip(
                label: 'IMC',
                value: bmi.toStringAsFixed(1),
                sub: bmiCategory,
                color: bmiColor,
              ),
              const SizedBox(width: 8),
              _ResultChip(
                label: 'TMB',
                value: '${bmr.round()} kcal',
                sub: 'metabolismo basal',
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              _ResultChip(
                label: 'Calorías',
                value: '${kcal.round()} kcal',
                sub: 'objetivo diario',
                color: const Color(0xFFE10600),
              ),
              const SizedBox(width: 8),
              _ResultChip(
                label: 'Proteína',
                value: '${protein.round()}g',
                sub: 'por día',
                color: const Color(0xFF4CAF50),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResultChip extends StatelessWidget {
  final String label, value, sub;
  final Color color;
  const _ResultChip({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              sub,
              style: const TextStyle(color: Colors.grey, fontSize: 8),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final now = DateTime.now();
    final days = [
      'Domingo',
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
    ];
    final todayName = days[now.weekday % 7];
    final todayWorkout = GymData.workoutPlan
        .where((w) => w.day == todayName)
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GYM SOCA'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner de bienvenida
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE10600), Color(0xFF8B0000)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Hola, ${user?.name ?? ''}! 💪',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Nivel: ${user?.level ?? ''} · Objetivo: ${user?.objective == 'musculo' ? 'Ganar músculo' : 'Perder grasa'}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  'Plan: ${user?.selectedPlan ?? 'Plan Premium'}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Stats row
          Row(
            children: [
              _StatCard(
                label: 'Entrenos',
                value: '${user?.workouts ?? 0}',
                icon: Icons.fitness_center,
              ),
              const SizedBox(width: 12),
              _StatCard(
                label: 'Racha',
                value: '${user?.streakDays ?? 0}d',
                icon: Icons.local_fire_department,
              ),
              const SizedBox(width: 12),
              _StatCard(
                label: 'Minutos',
                value: '${user?.totalMinutes ?? 0}',
                icon: Icons.timer,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Entrenamiento de hoy
          if (todayWorkout != null) ...[
            Text(
              'Entrenamiento de Hoy',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => context.go('/workouts'),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE10600).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE10600).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        color: Color(0xFFE10600),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            todayWorkout.focus,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            '${todayWorkout.exercises.length} ejercicios · ${todayWorkout.day}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          // Acceso rápido
          Text('Acceso Rápido', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.7,
            children: [
              _QuickCard(
                title: 'Rutinas',
                icon: Icons.fitness_center,
                color: const Color(0xFFE10600),
                onTap: () => context.go('/workouts'),
              ),
              _QuickCard(
                title: 'Tienda',
                icon: Icons.shopping_bag,
                color: const Color(0xFF4CAF50),
                onTap: () => context.go('/store'),
              ),
              _QuickCard(
                title: 'Clases',
                icon: Icons.calendar_today,
                color: const Color(0xFF2196F3),
                onTap: () => context.go('/reservations'),
              ),
              _QuickCard(
                title: 'Perfil',
                icon: Icons.person,
                color: const Color(0xFF9C27B0),
                onTap: () => context.go('/profile'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Consejo del día
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF141414),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb, color: Color(0xFFFFD700), size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Consejo del día',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getDailyTip(now.day),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Estadísticas corporales
          Text(
            'Estadísticas Corporales',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _BodyStatCard(
                label: 'Peso',
                value: '${user?.currentWeight.toStringAsFixed(1) ?? '-'} kg',
              ),
              const SizedBox(width: 12),
              _BodyStatCard(
                label: 'IMC',
                value: user != null && user.bmi > 0
                    ? user.bmi.toStringAsFixed(1)
                    : '-',
              ),
              const SizedBox(width: 12),
              _BodyStatCard(label: user?.bmiCategory ?? '-', value: ''),
            ],
          ),
          const SizedBox(height: 12),
          if (user != null && user.tdee > 0) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Plan Nutricional',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _MacroChip(
                        label: 'Calorías',
                        value: '${user.dailyCalories.round()} kcal',
                        color: const Color(0xFFE10600),
                      ),
                      const SizedBox(width: 8),
                      _MacroChip(
                        label: 'Proteína',
                        value: '${user.dailyProtein.round()}g',
                        color: const Color(0xFF4CAF50),
                      ),
                      const SizedBox(width: 8),
                      _MacroChip(
                        label: 'Carbs',
                        value: '${user.dailyCarbs.round()}g',
                        color: const Color(0xFF2196F3),
                      ),
                      const SizedBox(width: 8),
                      _MacroChip(
                        label: 'TDEE',
                        value: '${user.tdee.round()} kcal',
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  String _getDailyTip(int day) {
    const tips = [
      'Duerme 7-9 horas para optimizar la recuperación muscular.',
      'La proteína es clave: consume 1.6-2.2g por kg de peso corporal.',
      'La constancia supera a la intensidad. ¡Entrena aunque no tengas ganas!',
      'Hidratáte: bebe al menos 3 litros de agua al día.',
      'El descanso es parte del entrenamiento. Un músculo crece cuando descansa.',
      'La mente es el músculo más importante. ¡Mantén el enfoque!',
      'Varía tus ejercicios cada 6-8 semanas para seguir progresando.',
      'El calentamiento previene lesiones. Nunca lo saltes.',
      'Escucha a tu cuerpo: el dolor muscular es normal, el articular no.',
      'Registra tus pesos y repeticiones para medir tu progreso.',
    ];
    return tips[day % tips.length];
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFE10600), size: 22),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QuickCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _BodyStatCard extends StatelessWidget {
  final String label;
  final String value;
  const _BodyStatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFFE10600),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MacroChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 9),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final dayIdx = (now.weekday - 1).clamp(0, GymData.workoutPlan.length - 1);
    _tabController = TabController(
      length: GymData.workoutPlan.length,
      vsync: this,
      initialIndex: dayIdx,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutinas'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: const Color(0xFFE10600),
          labelColor: const Color(0xFFE10600),
          unselectedLabelColor: Colors.grey,
          tabs: GymData.workoutPlan
              .map((w) => Tab(text: w.day.substring(0, 3)))
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: GymData.workoutPlan
            .map((day) => _WorkoutDayView(day: day))
            .toList(),
      ),
    );
  }
}

class _WorkoutDayView extends ConsumerWidget {
  final WorkoutDay day;
  const _WorkoutDayView({required this.day});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final completed = user?.completedExercises ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE10600), Color(0xFF8B0000)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.fitness_center, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day.day,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  Text(
                    day.focus,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '${day.exercises.length} ejercs.',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        ...day.exercises.map(
          (ex) => _ExerciseCard(
            exercise: ex,
            isCompleted: completed.contains(ex.id),
            ref: ref,
          ),
        ),
      ],
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final bool isCompleted;
  final WidgetRef ref;
  const _ExerciseCard({
    required this.exercise,
    required this.isCompleted,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(12),
        border: isCompleted
            ? Border.all(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.6),
                width: 1.5,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFF4CAF50).withValues(alpha: 0.15)
                      : const Color(0xFFE10600).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  image: exercise.imagePath != null
                      ? DecorationImage(
                          image: AssetImage(exercise.imagePath!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: exercise.imagePath == null
                    ? Icon(
                        isCompleted ? Icons.check_circle : Icons.fitness_center,
                        color: isCompleted
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFE10600),
                        size: 22,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      exercise.muscleGroup,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _InfoChip(icon: Icons.repeat, label: '${exercise.series} series'),
              const SizedBox(width: 8),
              _InfoChip(
                icon: Icons.sports_score,
                label: '${exercise.reps} reps',
              ),
            ],
          ),
          if (exercise.tip.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: Color(0xFFFFD700),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      exercise.tip,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isCompleted
                  ? null
                  : () async {
                      await ref
                          .read(authProvider.notifier)
                          .completeExercise(exercise.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('✅ ${exercise.name} completado!'),
                            backgroundColor: const Color(0xFF4CAF50),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
              style: isCompleted
                  ? ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF4CAF50,
                      ).withValues(alpha: 0.3),
                      foregroundColor: const Color(0xFF4CAF50),
                    )
                  : null,
              child: Text(
                isCompleted ? '✓ Completado' : 'Marcar como completado',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.grey),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen> {
  String _filter = 'todos';
  static const categories = [
    {'key': 'todos', 'label': 'Todos'},
    {'key': 'suplementos', 'label': 'Suplementos'},
    {'key': 'accesorios', 'label': 'Accesorios'},
    {'key': 'ropa', 'label': 'Ropa'},
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final cartCount = user?.cartItems.length ?? 0;
    final products = _filter == 'todos'
        ? GymData.products
        : GymData.products.where((p) => p.category == _filter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tienda'),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () => _showCart(context, user),
              ),
              if (cartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE10600),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$cartCount',
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = categories[i];
                final isActive = _filter == cat['key'];
                return GestureDetector(
                  onTap: () => setState(() => _filter = cat['key']!),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFFE10600)
                          : const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cat['label']!,
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.72,
              ),
              itemCount: products.length,
              itemBuilder: (_, i) =>
                  _ProductCard(product: products[i], ref: ref, user: user),
            ),
          ),
        ],
      ),
    );
  }

  void _showCart(BuildContext context, User? user) {
    final cartIds = user?.cartItems ?? [];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        if (cartIds.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 60,
                  color: Colors.grey,
                ),
                SizedBox(height: 12),
                Text(
                  'Tu carrito está vacío',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }
        final cartProducts = cartIds
            .map((id) => GymData.products.where((p) => p.id == id).firstOrNull)
            .whereType<Product>()
            .toList();
        final total = cartProducts.fold(0, (sum, p) => sum + p.price);
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tu Carrito',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 12),
              ...cartProducts.map(
                (p) => ListTile(
                  leading: p.imagePath != null
                      ? SizedBox(
                          width: 40,
                          height: 40,
                          child: Image.asset(p.imagePath!, fit: BoxFit.cover),
                        )
                      : Icon(Icons.shopping_bag, color: p.color),
                  title: Text(p.name),
                  trailing: Text(
                    '\$${p.price}',
                    style: const TextStyle(color: Color(0xFFE10600)),
                  ),
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '\$$total',
                    style: const TextStyle(
                      color: Color(0xFFE10600),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('¡Pedido realizado con éxito! 🎉'),
                        backgroundColor: Color(0xFF4CAF50),
                      ),
                    );
                  },
                  child: const Text('Confirmar Pedido'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final WidgetRef ref;
  final User? user;
  const _ProductCard({
    required this.product,
    required this.ref,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final inCart = user?.cartItems.contains(product.id) ?? false;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(12),
        border: inCart
            ? Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.5))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 90,
            decoration: BoxDecoration(
              color: product.color.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              image: product.imagePath != null
                  ? DecorationImage(
                      image: AssetImage(product.imagePath!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: product.imagePath == null
                ? Icon(Icons.shopping_bag, color: product.color, size: 42)
                : null,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    product.description,
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Text(
                    '\$${product.price}',
                    style: const TextStyle(
                      color: Color(0xFFE10600),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: inCart
                          ? () => ref
                                .read(authProvider.notifier)
                                .removeFromCart(product.id)
                          : () => ref
                                .read(authProvider.notifier)
                                .addToCart(product.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: inCart
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFE10600),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        inCart ? '✓ En carrito' : '+ Agregar',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReservationsScreen extends ConsumerWidget {
  const ReservationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final myReservations = user?.reservations ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clases'),
        actions: [
          if (myReservations.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE10600).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${myReservations.length} clases',
                    style: const TextStyle(
                      color: Color(0xFFE10600),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (myReservations.isNotEmpty) ...[
            Text(
              'Mis Reservas',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1F0D),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                children: myReservations.map((key) {
                  final cls = GymData.classes
                      .where((c) => '${c.day}-${c.name}' == key)
                      .firstOrNull;
                  if (cls == null) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF4CAF50),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${cls.day} - ${cls.name}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        Text(
                          cls.time,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          Text(
            'Horario Semanal',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          ...GymData.classes.map((cls) {
            final key = '${cls.day}-${cls.name}';
            final isReserved = myReservations.contains(key);
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(12),
                border: isReserved
                    ? Border.all(
                        color: const Color(0xFF4CAF50).withValues(alpha: 0.5),
                      )
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isReserved
                              ? const Color(0xFF4CAF50).withValues(alpha: 0.15)
                              : const Color(0xFFE10600).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          image: cls.imagePath != null
                              ? DecorationImage(
                                  image: AssetImage(cls.imagePath!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: cls.imagePath == null
                            ? Icon(
                                Icons.fitness_center,
                                color: isReserved
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFFE10600),
                                size: 22,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cls.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              '${cls.day} · ${cls.time} · ${cls.duration}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        cls.instructor,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.group, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${cls.spots} cupos',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await ref
                            .read(authProvider.notifier)
                            .toggleReservation(key);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isReserved
                                    ? '❌ Reserva cancelada'
                                    : '✅ Clase reservada: ${cls.name}',
                              ),
                              backgroundColor: isReserved
                                  ? Colors.orange
                                  : const Color(0xFF4CAF50),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isReserved
                            ? Colors.orange
                            : const Color(0xFFE10600),
                      ),
                      child: Text(
                        isReserved ? 'Cancelar Reserva' : 'Reservar Clase',
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ============= SHELL + PROFILE =============
class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = switch (location) {
      '/home' => 0,
      '/workouts' => 1,
      '/store' => 2,
      '/reservations' => 3,
      '/profile' => 4,
      _ => 0,
    };
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF141414),
        indicatorColor: const Color(0xFFE10600).withValues(alpha: 0.2),
        selectedIndex: index,
        onDestinationSelected: (i) {
          const routes = [
            '/home',
            '/workouts',
            '/store',
            '/reservations',
            '/profile',
          ];
          context.go(routes[i]);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Rutinas',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: 'Tienda',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Clases',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          TextButton.icon(
            onPressed: () async {
              final router = GoRouter.of(context);
              await ref.read(authProvider.notifier).logout();
              router.go('/login');
            },
            icon: const Icon(Icons.logout, color: Color(0xFFE10600), size: 18),
            label: const Text(
              'Salir',
              style: TextStyle(color: Color(0xFFE10600)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: const Color(
                    0xFFE10600,
                  ).withValues(alpha: 0.2),
                  backgroundImage: AssetImage(
                    (user?.gender == 'femenino')
                        ? 'assets/img/mujercambio.jpeg'
                        : 'assets/img/hombrecambio.jpg',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.name ?? '',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE10600).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${user?.selectedPlan ?? 'Plan Premium'} · ${user?.level ?? ''}',
                    style: const TextStyle(
                      color: Color(0xFFE10600),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Estadísticas', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Row(
            children: [
              _StatCard(
                label: 'Entrenos',
                value: '${user?.workouts ?? 0}',
                icon: Icons.fitness_center,
              ),
              const SizedBox(width: 12),
              _StatCard(
                label: 'Racha',
                value: '${user?.streakDays ?? 0}d',
                icon: Icons.local_fire_department,
              ),
              const SizedBox(width: 12),
              _StatCard(
                label: 'Minutos',
                value: '${user?.totalMinutes ?? 0}',
                icon: Icons.timer,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Datos Corporales',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          _ProfileInfoRow(
            label: 'Peso inicial',
            value: '${user?.initialWeight.toStringAsFixed(1) ?? '-'} kg',
          ),
          _ProfileInfoRow(
            label: 'Peso actual',
            value: '${user?.currentWeight.toStringAsFixed(1) ?? '-'} kg',
          ),
          _ProfileInfoRow(
            label: 'Altura',
            value: user != null && user.height > 0
                ? '${user.height.round()} cm'
                : '-',
          ),
          _ProfileInfoRow(
            label: 'Edad',
            value: user != null && user.age > 0 ? '${user.age} años' : '-',
          ),
          _ProfileInfoRow(
            label: 'IMC',
            value: user != null && user.bmi > 0
                ? '${user.bmi.toStringAsFixed(1)} — ${user.bmiCategory}'
                : '-',
          ),
          _ProfileInfoRow(
            label: 'Masa muscular',
            value: '${user?.muscleMass.toStringAsFixed(1) ?? '-'} kg',
          ),
          _ProfileInfoRow(
            label: 'Grasa corporal',
            value: '${user?.bodyFat.toStringAsFixed(1) ?? '-'}%',
          ),
          if (user != null && user.tdee > 0) ...[
            const SizedBox(height: 20),
            Text(
              'Plan Nutricional Calculado',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            _ProfileInfoRow(
              label: 'Metabolismo Basal (TMB)',
              value: '${user.bmr.round()} kcal',
            ),
            _ProfileInfoRow(
              label: 'Gasto Total (TDEE)',
              value: '${user.tdee.round()} kcal',
            ),
            _ProfileInfoRow(
              label: 'Calorías objetivo',
              value: '${user.dailyCalories.round()} kcal',
            ),
            _ProfileInfoRow(
              label: 'Proteína diaria',
              value: '${user.dailyProtein.round()} g',
            ),
            _ProfileInfoRow(
              label: 'Carbohidratos diarios',
              value: '${user.dailyCarbs.round()} g',
            ),
            _ProfileInfoRow(
              label: 'Nivel de actividad',
              value:
                  const {
                    'sedentario': 'Sedentario',
                    'ligero': 'Ligero',
                    'moderado': 'Moderado',
                    'activo': 'Activo',
                    'muy_activo': 'Muy Activo',
                  }[user.activityLevel] ??
                  user.activityLevel,
            ),
          ],
          const SizedBox(height: 20),
          Text(
            'Objetivo & Plan',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          _ProfileInfoRow(
            label: 'Objetivo',
            value: user?.objective == 'musculo'
                ? 'Ganar Músculo'
                : 'Perder Grasa',
          ),
          _ProfileInfoRow(
            label: 'Nivel',
            value: user?.level == 'principiante' ? 'Principiante' : 'Avanzado',
          ),
          _ProfileInfoRow(
            label: 'Plan activo',
            value: user?.selectedPlan ?? 'Plan Premium',
          ),
          if ((user?.reservations.length ?? 0) > 0) ...[
            const SizedBox(height: 20),
            Text(
              'Mis Clases Reservadas',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            ...(user?.reservations ?? []).map((key) {
              final cls = GymData.classes
                  .where((c) => '${c.day}-${c.name}' == key)
                  .firstOrNull;
              if (cls == null) return const SizedBox();
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.event_available,
                      color: Color(0xFF4CAF50),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${cls.day} - ${cls.name}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Text(
                      cls.time,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              );
            }),
          ],
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _ProfileInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ============= MAIN =============
void main() {
  runApp(const ProviderScope(child: GymSocaApp()));
}

class GymSocaApp extends ConsumerWidget {
  const GymSocaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Gym Soca',
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
