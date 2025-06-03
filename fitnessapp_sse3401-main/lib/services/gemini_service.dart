import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String apiKey =
      'AIzaSyCmU4Yv2PHtXkysAnT2jUtiQxqM2rBzMxU'; // Replace with your API key
  final GenerativeModel model;

  GeminiService()
      : model = GenerativeModel(
          model: 'gemini-pro',
          apiKey: apiKey,
        );

  Future<String> getFitnessResponse(String prompt) async {
    try {
      final fullPrompt =
          "You are a fitness assistant named FitQuest AI Assistant. Focus on fitness, health, and workout topics. Don't response more than 200 words "
          "Format important terms or emphasis with markdown bold (**). "
          "User prompt: $prompt";

      final response = await model.generateContent([Content.text(fullPrompt)]);
      String text = response.text ?? 'Sorry, I could not generate a response.';

      // Convert markdown bold syntax to HTML bold tags
      text = text.replaceAllMapped(
          RegExp(r'\*\*(.*?)\*\*'), (match) => '<b>${match.group(1)}</b>');

      return text;
    } catch (e) {
      return 'Error: $e';
    }
  }
}
