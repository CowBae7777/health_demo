import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:health/health.dart';

class HttpService {
  static const String baseUrl = 'https://health-weiiii-default-rtdb.firebaseio.com/healthdemo';

  static Future<void> uploadHealthData(List<HealthDataPoint> healthDataList, String dataType) async {
    List<Map<String, dynamic>> data = healthDataList.map((data) => {
      'type': data.typeString,
      'value': data.value,
      'date_from': data.dateFrom.toString(),
      'date_to': data.dateTo.toString(),
    }).toList();

    final response = await http.post(
      Uri.parse('$baseUrl/$dataType.json'),
      body: json.encode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to upload health data');
    }
  }
}

