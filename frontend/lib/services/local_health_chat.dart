/// Offline health assistant — simple rule-based responses.
/// No network required.
String getLocalHealthResponse(String userMessage) {
  final msg = userMessage.toLowerCase();

  // Headache / Head pain
  if (_contains(msg, ['headache', 'head pain', 'migraine', 'head ache'])) {
    return '🤕 **Headache** can be caused by dehydration, tension, poor sleep, or eye strain.\n\n'
        '**What you can try:**\n'
        '• Drink 2–3 glasses of water\n'
        '• Rest in a quiet, dark room\n'
        '• Apply a cold or warm compress to your forehead\n'
        '• Over-the-counter pain relievers (e.g. paracetamol) can help\n\n'
        '⚠️ See a doctor if the headache is sudden and severe, or lasts more than 3 days.';
  }

  // Fever
  if (_contains(msg, ['fever', 'high temperature', 'temperature', '38', '39', '40'])) {
    return '🌡️ **Fever** is your body fighting an infection.\n\n'
        '**What you can try:**\n'
        '• Stay hydrated — drink plenty of fluids\n'
        '• Rest and avoid strenuous activity\n'
        '• Use a light, breathable blanket\n'
        '• Paracetamol or ibuprofen can reduce temperature\n\n'
        '⚠️ Seek immediate care if fever exceeds 39.5 °C (103 °F), or is accompanied by rash, stiff neck, or confusion.';
  }

  // Cold / Flu
  if (_contains(msg, ['cold', 'flu', 'runny nose', 'sneezing', 'cough', 'sore throat'])) {
    return '🤧 **Cold / Flu** symptoms usually resolve within 7–10 days.\n\n'
        '**What you can try:**\n'
        '• Rest as much as possible\n'
        '• Stay hydrated — warm fluids like herbal tea or soup are great\n'
        '• Use saline nasal spray for congestion\n'
        '• Honey and lemon can soothe a sore throat\n'
        '• Over-the-counter antihistamines or decongestants may help\n\n'
        '⚠️ See a doctor if symptoms worsen after 5 days, or if you have difficulty breathing.';
  }

  // Chest pain
  if (_contains(msg, ['chest pain', 'chest pressure', 'heart pain', 'tightness in chest'])) {
    return '🚨 **Chest pain requires immediate attention.**\n\n'
        'Chest pain can be a sign of a heart attack or other serious condition.\n\n'
        '**Please:**\n'
        '• Call emergency services (ambulance) immediately\n'
        '• Sit or lie down and rest\n'
        '• Do not drive yourself to the hospital\n'
        '• If available and advised, take aspirin 300mg\n\n'
        '⚠️ Do not ignore chest pain — always treat it as an emergency until ruled out by a doctor.';
  }

  // Stomach / Abdomen
  if (_contains(msg, ['stomach ache', 'stomach pain', 'abdominal pain', 'belly pain', 'nausea', 'vomiting', 'diarrhea', 'diarrhoea', 'indigestion'])) {
    return '🤢 **Stomach issues** can be caused by food, stress, or infections.\n\n'
        '**What you can try:**\n'
        '• Eat light, bland foods (rice, toast, bananas)\n'
        '• Stay hydrated — take small sips of water or oral rehydration salts\n'
        '• Avoid fatty, spicy, or dairy foods temporarily\n'
        '• Rest your digestive system\n\n'
        '⚠️ See a doctor if pain is severe, if you have blood in stools or vomit, or if symptoms last more than 48 hours.';
  }

  // Back pain
  if (_contains(msg, ['back pain', 'lower back', 'backache', 'spine pain'])) {
    return '🦴 **Back pain** is very common and usually not serious.\n\n'
        '**What you can try:**\n'
        '• Apply ice for the first 48 hrs, then switch to heat\n'
        '• Take over-the-counter anti-inflammatories (e.g. ibuprofen)\n'
        '• Gentle stretching and walking can help\n'
        '• Avoid prolonged bed rest — gentle movement is better\n\n'
        '⚠️ See a doctor if pain radiates down your leg, is severe, or follows an injury.';
  }

  // Dizziness
  if (_contains(msg, ['dizzy', 'dizziness', 'lightheaded', 'vertigo', 'spinning'])) {
    return '💫 **Dizziness** can have many causes, most of them harmless.\n\n'
        '**What you can try:**\n'
        '• Sit or lie down immediately to prevent falls\n'
        '• Drink water — dehydration is a common cause\n'
        '• Eat something if you haven\'t recently (low blood sugar)\n'
        '• Rise slowly from sitting or lying positions\n\n'
        '⚠️ Seek immediate care if dizziness is accompanied by chest pain, hearing loss, or vision changes.';
  }

  // Fatigue / Tiredness
  if (_contains(msg, ['tired', 'fatigue', 'exhausted', 'no energy', 'weakness', 'weak'])) {
    return '😴 **Fatigue** is often linked to lifestyle factors.\n\n'
        '**What you can try:**\n'
        '• Aim for 7–9 hours of quality sleep per night\n'
        '• Eat balanced meals with adequate iron and vitamins\n'
        '• Stay hydrated throughout the day\n'
        '• Light exercise can actually boost energy levels\n'
        '• Reduce caffeine and screen time before bed\n\n'
        '⚠️ See a doctor if fatigue is persistent and unexplained, as it can indicate anaemia, thyroid issues, or other conditions.';
  }

  // Blood pressure
  if (_contains(msg, ['blood pressure', 'hypertension', 'bp', 'high bp', 'low bp', 'hypotension'])) {
    return '❤️ **Blood Pressure** monitoring is important for heart health.\n\n'
        '**Normal range:** Systolic 90–120 / Diastolic 60–80 mmHg\n\n'
        '**For high BP:**\n'
        '• Reduce salt intake\n'
        '• Exercise regularly\n'
        '• Limit alcohol and caffeine\n'
        '• Manage stress\n\n'
        '**For low BP:**\n'
        '• Increase fluid and salt intake slightly\n'
        '• Rise slowly from sitting/lying\n'
        '• Eat smaller, more frequent meals\n\n'
        '⚠️ See a doctor if readings are consistently outside the normal range.';
  }

  // Diabetes / Blood sugar
  if (_contains(msg, ['diabetes', 'blood sugar', 'glucose', 'insulin', 'sugar level'])) {
    return '🩸 **Blood Sugar Management** is essential for diabetic health.\n\n'
        '**Normal fasting glucose:** 70–100 mg/dL (3.9–5.6 mmol/L)\n\n'
        '**What helps:**\n'
        '• Eat regular, balanced meals with low glycaemic index foods\n'
        '• Exercise for at least 30 minutes daily\n'
        '• Monitor blood glucose as directed by your doctor\n'
        '• Stay well hydrated\n'
        '• Avoid sugary drinks and processed foods\n\n'
        '⚠️ If you have known diabetes and your sugar is very high or very low, contact your healthcare provider.';
  }

  // Breathing / Shortness of breath
  if (_contains(msg, ['breathing', 'shortness of breath', 'breathless', 'asthma', 'wheeze'])) {
    return '🫁 **Breathing difficulty** should not be ignored.\n\n'
        '**For mild breathlessness:**\n'
        '• Sit upright and try to stay calm\n'
        '• Practice pursed-lip breathing\n'
        '• Use your prescribed inhaler if you have asthma\n\n'
        '⚠️ **Call emergency services immediately** if:\n'
        '• Breathlessness is sudden and severe\n'
        '• Lips or fingernails turn bluish\n'
        '• There is chest pain alongside the breathlessness';
  }

  // Sleep
  if (_contains(msg, ['sleep', 'insomnia', "can't sleep", 'sleeping'])) {
    return '😴 **Sleep issues** are very common and usually manageable.\n\n'
        '**Tips for better sleep:**\n'
        '• Keep a consistent sleep schedule (same bed/wake time daily)\n'
        '• Avoid screens 1 hour before bed\n'
        '• Keep your bedroom cool, dark, and quiet\n'
        '• Avoid caffeine after 2 PM\n'
        '• Try relaxation techniques like deep breathing or meditation\n\n'
        '⚠️ See a doctor if insomnia persists for more than 3 weeks, as it may indicate anxiety or depression.';
  }

  // Anxiety / Stress / Mental health
  if (_contains(msg, ['anxiety', 'stress', 'panic', 'worried', 'mental health', 'depression', 'sad', 'depressed'])) {
    return '🧠 **Mental health** is just as important as physical health.\n\n'
        '**What can help:**\n'
        '• Deep breathing: inhale for 4 s, hold 4 s, exhale 4 s\n'
        '• Regular physical activity (even a 20-min walk)\n'
        '• Talk to someone you trust\n'
        '• Limit caffeine and alcohol\n'
        '• Practice mindfulness or meditation\n\n'
        '⚠️ Please reach out to a mental health professional or helpline if you\'re feeling overwhelmed. You don\'t have to face this alone.';
  }

  // Greetings
  if (_contains(msg, ['hello', 'hi', 'hey', 'good morning', 'good afternoon', 'good evening'])) {
    return '👋 Hello! I\'m your offline Health Assistant.\n\n'
        'I can help you understand common symptoms and suggest general wellness tips. '
        'Type in your symptoms or a health question and I\'ll do my best to guide you.\n\n'
        '💡 Remember: I\'m for informational purposes only. Always consult a qualified doctor for medical advice.';
  }

  // Thank you
  if (_contains(msg, ['thank', 'thanks', 'thank you'])) {
    return '😊 You\'re welcome! Stay healthy and don\'t hesitate to ask if you have more questions.\n\n'
        '💡 Remember to consult a healthcare professional for any persistent or serious concerns.';
  }

  // Default fallback
  return '🩺 I\'m not sure I fully understood your question, but here are some general wellness tips:\n\n'
      '• Stay hydrated — aim for 8 glasses of water daily\n'
      '• Get 7–9 hours of sleep\n'
      '• Eat a balanced diet rich in fruits and vegetables\n'
      '• Exercise regularly\n'
      '• Manage stress with relaxation techniques\n\n'
      'Try rephrasing your symptoms (e.g. "I have a headache", "I feel tired") for more specific advice.\n\n'
      '⚠️ For any medical concerns, always consult a qualified healthcare professional.';
}

bool _contains(String message, List<String> keywords) {
  return keywords.any((k) => message.contains(k));
}
