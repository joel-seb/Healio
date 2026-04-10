# Disease Prediction Chat Interface

## Overview
A chat-based UI for disease prediction using machine learning models (Random Forest, Naive Bayes, or SVM).

## Features
- Clean chat interface matching the app's theme
- Message bubbles for user and AI responses
- Warning/disclaimer messages
- Timestamp display
- Smooth scrolling
- Text input with send functionality
- Placeholder for ML model integration

## How to Use

### 1. Navigate to the Chat Screen

Add this to your dashboard or any screen where you want to access disease prediction:

```dart
import 'package:healio/screens/disease_prediction_chat.dart';

// In your button or card onTap:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const DiseasePredictionChat(),
  ),
);
```

### 2. Integrate Your ML Model

When you're ready to integrate your Random Forest, Naive Bayes, or SVM model:

#### Option A: API Integration (Recommended)

Replace the placeholder response in the `_sendMessage()` method:

```dart
void _sendMessage() async {
  if (_messageController.text.trim().isEmpty) return;

  final userMessage = _messageController.text;
  
  setState(() {
    _messages.add(
      ChatMessage(
        text: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );
  });

  _messageController.clear();

  try {
    // Call your ML API
    final response = await http.post(
      Uri.parse('YOUR_API_ENDPOINT'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'symptoms': userMessage,
        'model': 'random_forest', // or 'naive_bayes', 'svm'
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      setState(() {
        _messages.add(
          ChatMessage(
            text: "Predicted Disease: ${data['disease']}\n"
                  "Confidence: ${data['confidence']}%\n\n"
                  "Please consult a healthcare professional for accurate diagnosis.",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    }
  } catch (e) {
    setState(() {
      _messages.add(
        ChatMessage(
          text: "Error processing request. Please try again.",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  _scrollToBottom();
}
```

#### Option B: On-Device ML (TensorFlow Lite)

If using TensorFlow Lite for on-device inference:

1. Add dependency to `pubspec.yaml`:
```yaml
dependencies:
  tflite_flutter: ^0.10.0
```

2. Place your `.tflite` model in `assets/ml/`

3. Update the prediction logic:
```dart
import 'package:tflite_flutter/tflite_flutter.dart';

class _DiseasePredictionChatState extends State<DiseasePredictionChat> {
  late Interpreter _interpreter;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/ml/disease_model.tflite');
  }

  Future<String> _predictDisease(String symptoms) async {
    // Preprocess symptoms
    var input = _preprocessSymptoms(symptoms);
    
    // Run inference
    var output = List.filled(1 * 10, 0).reshape([1, 10]);
    _interpreter.run(input, output);
    
    // Get predicted disease
    return _getDiseaseName(output);
  }
}
```

## ML Model Integration Guide

### Expected Input Format
The symptoms should be processed into a format your model expects. Common approaches:

1. **Symptom List**: Convert text to a list of symptoms
2. **Feature Vector**: One-hot encode or numerical features
3. **Text Embedding**: Use NLP models for text understanding

### Expected Output Format
Your ML model should return:
- Predicted disease name
- Confidence score
- Optional: Top 3 predictions
- Optional: Recommended actions

### Sample Dataset Structure
```python
# Example training data format
symptoms = [
    ['fever', 'cough', 'fatigue'],
    ['headache', 'nausea', 'dizziness'],
    # ...
]
diseases = ['Flu', 'Migraine', ...]
```

## Customization

### Change Colors
Edit the color constants in `disease_prediction_chat.dart`:
- AI bubble: `Color(0xFFE8EAF6)`
- User bubble: `Color(0xFF4DB6AC)`
- Warning bubble: `Color(0xFFFFF4E5)`

### Modify Initial Message
Edit the `initState()` method to customize the greeting and disclaimer.

### Add More Features
- Voice input
- Symptom suggestions/autocomplete
- Medical history context
- Export chat history
- Multi-language support

## Testing
Test the UI without ML integration:
```bash
flutter run
```

The placeholder responses will simulate the chat flow.

## Security & Privacy
⚠️ **Important**:
- Never store sensitive health data without encryption
- Comply with HIPAA/GDPR if applicable
- Always include medical disclaimers
- Don't make definitive diagnoses
- Recommend professional consultation

## Next Steps
1. Train your ML model (Random Forest/NB/SVM)
2. Deploy model as API or convert to TFLite
3. Integrate prediction logic
4. Test with real symptom data
5. Add analytics and monitoring

## Support
For ML model integration help, refer to:
- scikit-learn documentation (for RF/NB/SVM)
- TensorFlow Lite Flutter documentation
- Your backend framework's API documentation
