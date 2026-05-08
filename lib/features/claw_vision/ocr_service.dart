import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  static Future<String> extractText(String imagePath) async {
    final textRecognizer = TextRecognizer();

    final inputImage = InputImage.fromFilePath(imagePath);

    final recognizedText =
        await textRecognizer.processImage(inputImage);

    await textRecognizer.close();

    return recognizedText.text;
  }
}