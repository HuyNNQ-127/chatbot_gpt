import 'package:http/http.dart' as http;
import 'dart:convert';

String openAIKey = '';

void _getOldOpenAIKey() async {
  final url = Uri.https(
      'test-firebase-3d494-default-rtdb.asia-southeast1.firebasedatabase.app',
      'openai-key.json');
  try {
    final response = await http.get(url);
    final Map<String, dynamic> listData = json.decode(response.body);
    for (final itemData in listData.entries) {
      openAIKey = itemData.value['OpenAIkey'];
    }
  } catch (e) {}
}
