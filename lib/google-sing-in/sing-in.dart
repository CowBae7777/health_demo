import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:health/health.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HealthDataPage(),
    );
  }
}

class HealthDataPage extends StatefulWidget {
  @override
  _HealthDataPageState createState() => _HealthDataPageState();
}

class _HealthDataPageState extends State<HealthDataPage> {
  List<HealthDataPoint> _healthDataList = [];
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/fitness.activity.read',
      'https://www.googleapis.com/auth/fitness.body.read',
    ],
  );

  @override
  void initState() {
    super.initState();
    _handleSignIn();
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
      fetchHealthData();
    } catch (error) {
      print(error);
    }
  }

  Future<void> fetchHealthData() async {
    HealthFactory health = HealthFactory();

    List<HealthDataType> types = [
      HealthDataType.STEPS,
      HealthDataType.HEART_RATE,
      // 根據需要添加其他數據類型
    ];

    bool requested = await health.requestAuthorization(types);

    if (requested) {
      List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
        DateTime.now().subtract(Duration(days: 1)),
        DateTime.now(),
        types,
      );
      setState(() {
        _healthDataList = HealthFactory.removeDuplicates(healthData);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('健康數據'),
      ),
      body: ListView.builder(
        itemCount: _healthDataList.length,
        itemBuilder: (context, index) {
          HealthDataPoint data = _healthDataList[index];
          return ListTile(
            title: Text('${data.typeString}: ${data.value}'),
            subtitle: Text('${data.dateFrom} - ${data.dateTo}'),
          );
        },
      ),
    );
  }
}
