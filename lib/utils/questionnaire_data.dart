class QuestionnaireData {
  static Map<String, List<QuestionModel>> getQuestionsByCondition(
      List<String> conditions,
      ) {
    // Get questions based on user's conditions
    final questions = <String, List<QuestionModel>>{};

    if (conditions.contains('diabetes') || conditions.contains('diabète')) {
      questions['diabetes'] = diabetesQuestions;
    }
    if (conditions.contains('hypertension') || conditions.contains('HTA')) {
      questions['hypertension'] = hypertensionQuestions;
    }
    if (conditions.contains('asthma') || conditions.contains('asthme')) {
      questions['asthma'] = asthmaQuestions;
    }

    // Always include general questions
    questions['general'] = generalQuestions;

    return questions;
  }

  // General Health Questions
  static final List<QuestionModel> generalQuestions = [
    QuestionModel(
      id: 'general_feeling',
      question: 'Comment vous sentez-vous aujourd\'hui ?',
      type: QuestionType.scale,
      options: [
        '😣 Très mal',
        '😟 Pas bien',
        '😐 Moyen',
        '🙂 Bien',
        '😊 Très bien',
      ],
    ),
    QuestionModel(
      id: 'sleep_quality',
      question: 'Comment avez-vous dormi la nuit dernière ?',
      type: QuestionType.multipleChoice,
      options: [
        'Très bien',
        'Bien',
        'Moyen',
        'Mal',
        'Très mal',
      ],
    ),
  ];

  // Diabetes Questions
  static final List<QuestionModel> diabetesQuestions = [
    QuestionModel(
      id: 'diabetes_thirst',
      question: 'Avez-vous ressenti une soif excessive ?',
      type: QuestionType.multipleChoice,
      options: [
        'Non, normal',
        'Un peu plus que d\'habitude',
        'Oui, beaucoup',
      ],
    ),
    QuestionModel(
      id: 'diabetes_urination',
      question: 'Avez-vous eu des mictions fréquentes ?',
      type: QuestionType.multipleChoice,
      options: [
        'Non, normal',
        'Un peu plus que d\'habitude',
        'Oui, très fréquent',
      ],
    ),
    QuestionModel(
      id: 'diabetes_fatigue',
      question: 'Avez-vous ressenti de la fatigue ?',
      type: QuestionType.multipleChoice,
      options: [
        'Non',
        'Fatigue légère',
        'Fatigue modérée',
        'Fatigue intense',
      ],
    ),
  ];

  // Hypertension Questions
  static final List<QuestionModel> hypertensionQuestions = [
    QuestionModel(
      id: 'hta_headache',
      question: 'Avez-vous eu des maux de tête ?',
      type: QuestionType.multipleChoice,
      options: [
        'Non',
        'Légers',
        'Modérés',
        'Intenses',
      ],
    ),
    QuestionModel(
      id: 'hta_dizziness',
      question: 'Avez-vous ressenti des vertiges ?',
      type: QuestionType.multipleChoice,
      options: [
        'Non',
        'Légers',
        'Modérés',
        'Intenses',
      ],
    ),
  ];

  // Asthma Questions
  static final List<QuestionModel> asthmaQuestions = [
    QuestionModel(
      id: 'asthma_breathing',
      question: 'Avez-vous eu des difficultés à respirer ?',
      type: QuestionType.multipleChoice,
      options: [
        'Non',
        'Légères',
        'Modérées',
        'Sévères',
      ],
    ),
    QuestionModel(
      id: 'asthma_wheezing',
      question: 'Avez-vous eu une respiration sifflante ?',
      type: QuestionType.multipleChoice,
      options: [
        'Non',
        'Occasionnelle',
        'Fréquente',
        'Constante',
      ],
    ),
    QuestionModel(
      id: 'asthma_inhaler',
      question: 'Avez-vous utilisé votre inhalateur de secours ?',
      type: QuestionType.multipleChoice,
      options: [
        'Non',
        'Une fois',
        '2-3 fois',
        'Plus de 3 fois',
      ],
    ),
  ];
}

enum QuestionType {
  multipleChoice,
  scale,
  yesNo,
}

class QuestionModel {
  final String id;
  final String question;
  final QuestionType type;
  final List<String> options;

  QuestionModel({
    required this.id,
    required this.question,
    required this.type,
    required this.options,
  });
}