// import 'package:flutter/material.dart';
// import 'package:health/health.dart';
//
// void main() {
//   runApp(MaterialApp(
//     home: HealthTestPage(),
//   ));
// }
//
// class HealthTestPage extends StatefulWidget {
//   @override
//   _HealthTestPageState createState() => _HealthTestPageState();
// }
//
// class _HealthTestPageState extends State<HealthTestPage> {
//   List<HealthDataPoint> _stepsData = [];
//   List<HealthDataPoint> _heartRateData = [];
//
//   @override
//   void initState() {
//     super.initState();
//     fetchHealthData();
//   }
//
//   Future<void> fetchHealthData() async {
//     HealthFactory health = HealthFactory();
//     bool requested = await health.requestAuthorization([
//       HealthDataType.STEPS,
//       HealthDataType.HEART_RATE,
//     ]);
//
//     if (requested) {
//       List<HealthDataPoint> stepsData = await health.getHealthDataFromTypes(
//         DateTime.now().subtract(Duration(days: 7)),
//         DateTime.now(),
//         [HealthDataType.STEPS],
//       );
//       List<HealthDataPoint> heartRateData = await health.getHealthDataFromTypes(
//         DateTime.now().subtract(Duration(days: 7)),
//         DateTime.now(),
//         [HealthDataType.HEART_RATE],
//       );
//       setState(() {
//         _stepsData.addAll(stepsData);
//         _heartRateData.addAll(heartRateData);
//       });
//     }
//   }
//
//   void _navigateToDetailPage(List<HealthDataPoint> data, String title) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => HealthDetailPage(data: data, title: title),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Health Test'),
//       ),
//       body: Column(
//         children: [
//           ListTile(
//             title: Text("Steps"),
//             trailing: Icon(Icons.arrow_forward),
//             onTap: () => _navigateToDetailPage(_stepsData, "Steps"),
//           ),
//           ListTile(
//             title: Text("Heart Rate"),
//             trailing: Icon(Icons.arrow_forward),
//             onTap: () => _navigateToDetailPage(_heartRateData, "Heart Rate"),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class HealthDetailPage extends StatelessWidget {
//   final List<HealthDataPoint> data;
//   final String title;
//
//   HealthDetailPage({required this.data, required this.title});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(title),
//       ),
//       body: ListView.builder(
//         itemCount: data.length,
//         itemBuilder: (context, index) {
//           HealthDataPoint point = data[index];
//           return ListTile(
//             title: Text("${point.value}"),
//             subtitle: Text("${point.dateFrom} - ${point.dateTo}"),
//           );
//         },
//       ),
//     );
//   }
// }

//v2
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: HomeScreen(),
//     );
//   }
// }
//
// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   final String databaseUrl = "https://health-weiiii-default-rtdb.firebaseio.com/healthdemo";
//   List<dynamic> analysisData = [];
//
//   Future<void> _sendData(Map<String, dynamic> data) async {
//     final response = await http.post(
//       Uri.parse("$databaseUrl/heart_rate_steps.json"),
//       body: json.encode(data),
//     );
//     if (response.statusCode == 200) {
//       print("Data sent successfully!");
//       _fetchAnalysisData();
//     } else {
//       print("Failed to send data!");
//     }
//   }
//
//   Future<void> _fetchAnalysisData() async {
//     final response = await http.get(Uri.parse("$databaseUrl/analysis.json"));
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body) as Map<String, dynamic>;
//       setState(() {
//         analysisData = data.values.toList();
//       });
//       print("Analysis data fetched successfully: $analysisData");
//     } else {
//       print("Failed to fetch analysis data!");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Firebase HTTP Demo"),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () {
//                 // 模擬數據
//                 final Map<String, dynamic> sampleData = {
//                   "heart_rate": 75,
//                   "steps": 1500,
//                   "timestamp": DateTime.now().toIso8601String()
//                 };
//                 _sendData(sampleData);
//               },
//               child: Text("Send Data"),
//             ),
//             ElevatedButton(
//               onPressed: _fetchAnalysisData,
//               child: Text("Fetch Analysis Data"),
//             ),
//             analysisData.isNotEmpty
//                 ? Expanded(
//               child: ListView.builder(
//                 itemCount: analysisData.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     title: Text(analysisData[index].toString()),
//                   );
//                 },
//               ),
//             )
//                 : Text("No analysis data available"),
//           ],
//         ),
//       ),
//     );
//   }
// }

//v4

// import 'package:flutter/material.dart';
// import 'package:health/health.dart';
// import 'http_service.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: HomeScreen(),
//     );
//   }
// }
//
// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   List<HealthDataPoint> _healthDataList = [];
//   bool _isAuthorized = false;
//   bool isUploading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchData();
//   }
//
//   Future<void> fetchData() async {
//     HealthFactory health = HealthFactory();
//
//     List<HealthDataType> types = [
//       HealthDataType.STEPS,
//       HealthDataType.HEART_RATE,
//     ];
//
//     bool requested = await health.requestAuthorization(types);
//
//     if (requested) {
//       setState(() {
//         _isAuthorized = true;
//       });
//
//       DateTime endDate = DateTime.now();
//       DateTime startDate = endDate.subtract(Duration(days: 30));
//
//       List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(startDate, endDate, types);
//       setState(() {
//         _healthDataList = healthData;
//       });
//     } else {
//       setState(() {
//         _isAuthorized = false;
//       });
//     }
//   }
//
//   Future<void> uploadData() async {
//     setState(() {
//       isUploading = true;
//     });
//     try {
//       await HttpService.uploadHealthData(_healthDataList);
//       showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: Text("上傳完畢"),
//             content: Text("數據已成功上傳至資料庫"),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Text("OK"),
//               ),
//             ],
//           );
//         },
//       );
//     } catch (e) {
//       print("Error uploading data: $e");
//     }
//     setState(() {
//       isUploading = false;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("健康數據管理"),
//       ),
//       body: _isAuthorized
//           ? Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: _healthDataList.length,
//               itemBuilder: (context, index) {
//                 HealthDataPoint data = _healthDataList[index];
//                 return ListTile(
//                   title: Text("${data.typeString}: ${data.value}"),
//                   subtitle: Text("日期: ${data.dateFrom} - ${data.dateTo}"),
//                 );
//               },
//             ),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               ElevatedButton(
//                 onPressed: fetchData,
//                 child: Text("重新加載數據"),
//               ),
//               ElevatedButton(
//                 onPressed: uploadData,
//                 child: Text("上傳數據"),
//               ),
//             ],
//           ),
//         ],
//       )
//           : Center(
//         child: Text("未授權讀取健康數據"),
//       ),
//     );
//   }
// }


//v5

// import 'package:flutter/material.dart';
// import 'package:health/health.dart';
// import 'http_service.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: HomeScreen(),
//     );
//   }
// }
//
// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   List<HealthDataPoint> _stepsDataList = [];
//   List<HealthDataPoint> _heartRateDataList = [];
//   bool _isAuthorized = false;
//   bool isUploading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchData();
//   }
//
//   Future<void> fetchData() async {
//     HealthFactory health = HealthFactory();
//
//     List<HealthDataType> types = [
//       HealthDataType.STEPS,
//       HealthDataType.HEART_RATE,
//     ];
//
//     bool requested = await health.requestAuthorization(types);
//
//     if (requested) {
//       setState(() {
//         _isAuthorized = true;
//       });
//
//       DateTime endDate = DateTime.now();
//       DateTime startDate = endDate.subtract(Duration(days: 30));
//
//       List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(startDate, endDate, types);
//       setState(() {
//         _stepsDataList = healthData.where((data) => data.type == HealthDataType.STEPS).toList();
//         _heartRateDataList = healthData.where((data) => data.type == HealthDataType.HEART_RATE).toList();
//       });
//     } else {
//       setState(() {
//         _isAuthorized = false;
//       });
//     }
//   }
//
//   Future<void> uploadData() async {
//     setState(() {
//       isUploading = true;
//     });
//     try {
//       await HttpService.uploadHealthData(_stepsDataList, 'steps');
//       await HttpService.uploadHealthData(_heartRateDataList, 'heartRate');
//       showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: Text("上傳完畢"),
//             content: Text("數據已成功上傳至資料庫"),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Text("OK"),
//               ),
//             ],
//           );
//         },
//       );
//     } catch (e) {
//       print("Error uploading data: $e");
//     }
//     setState(() {
//       isUploading = false;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("健康數據管理"),
//       ),
//       body: _isAuthorized
//           ? Column(
//         children: [
//           Expanded(
//             child: ListView(
//               children: [
//                 ListTile(
//                   title: Text("步數"),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => DataListScreen(dataList: _stepsDataList, title: "步數"),
//                       ),
//                     );
//                   },
//                 ),
//                 ListTile(
//                   title: Text("心律"),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => DataListScreen(dataList: _heartRateDataList, title: "心律"),
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               ElevatedButton(
//                 onPressed: fetchData,
//                 child: Text("重新加載數據"),
//               ),
//               ElevatedButton(
//                 onPressed: uploadData,
//                 child: Text("上傳數據"),
//               ),
//             ],
//           ),
//         ],
//       )
//           : Center(
//         child: Text("未授權讀取健康數據"),
//       ),
//     );
//   }
// }
//
// class DataListScreen extends StatelessWidget {
//   final List<HealthDataPoint> dataList;
//   final String title;
//
//   DataListScreen({required this.dataList, required this.title});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(title),
//       ),
//       body: ListView.builder(
//         itemCount: dataList.length,
//         itemBuilder: (context, index) {
//           HealthDataPoint data = dataList[index];
//           return ListTile(
//             title: Text("${data.typeString}: ${data.value}"),
//             subtitle: Text("日期: ${data.dateFrom} - ${data.dateTo}"),
//           );
//         },
//       ),
//     );
//   }
// }

//v6
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'http_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  List<HealthDataPoint> _stepsDataList = [];
  List<HealthDataPoint> _heartRateDataList = [];
  bool _isAuthorized = false;
  bool isUploading = false;
  List<String> _analysisResults = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    HealthFactory health = HealthFactory();

    List<HealthDataType> types = [
      HealthDataType.STEPS,
      HealthDataType.HEART_RATE,
    ];

    bool requested = await health.requestAuthorization(types);

    if (requested) {
      setState(() {
        _isAuthorized = true;
      });

      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(Duration(days: 30));

      List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(startDate, endDate, types);
      setState(() {
        _stepsDataList = healthData.where((data) => data.type == HealthDataType.STEPS).toList();
        _heartRateDataList = healthData.where((data) => data.type == HealthDataType.HEART_RATE).toList();
        _analysisResults = analyzeData(_stepsDataList, _heartRateDataList);
      });
    } else {
      setState(() {
        _isAuthorized = false;
      });
    }
  }

  double getNumericValue(HealthDataPoint data) {
    if (data.value is Map) {
      var valueMap = data.value as Map;
      if (valueMap.containsKey('numericValue')) {
        return double.tryParse(valueMap['numericValue'].toString()) ?? 0.0;
      }
    }
    return 0.0;
  }


  List<String> analyzeData(List<HealthDataPoint> stepsData, List<HealthDataPoint> heartRateData) {
    List<String> results = [];

    // 簡單的分析邏輯
    for (int i = 0; i < stepsData.length; i++) {
      if (i < heartRateData.length) {
        var step = stepsData[i];
        var heartRate = heartRateData[i];

        double stepValue = getNumericValue(step);
        double heartRateValue = getNumericValue(heartRate);

        if (stepValue > 100 && heartRateValue > 90) {
          results.add('可能在 ${step.dateFrom} 抽煙');
        } else if (heartRateValue < 60 && step.dateFrom.hour > 22) {
          results.add('可能在 ${step.dateFrom} 睡覺');
        }
      }
    }

    return results;
  }

  Future<void> uploadData() async {
    setState(() {
      isUploading = true;
    });
    try {
      await HttpService.uploadHealthData(_stepsDataList, 'steps');
      await HttpService.uploadHealthData(_heartRateDataList, 'heartRate');
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("上傳完畢"),
            content: Text("數據已成功上傳至資料庫"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print("Error uploading data: $e");
    }
    setState(() {
      isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("健康數據管理"),
      ),
      body: _isAuthorized
          ? Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: Text("步數"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DataListScreen(dataList: _stepsDataList, title: "步數"),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Text("心律"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DataListScreen(dataList: _heartRateDataList, title: "心律"),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: fetchData,
                child: Text("重新加載數據"),
              ),
              ElevatedButton(
                onPressed: uploadData,
                child: Text("上傳數據"),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _analysisResults.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_analysisResults[index]),
                );
              },
            ),
          ),
        ],
      )
          : Center(
        child: Text("未授權讀取健康數據"),
      ),
    );
  }
}

class DataListScreen extends StatelessWidget {
  final List<HealthDataPoint> dataList;
  final String title;

  DataListScreen({required this.dataList, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView.builder(
        itemCount: dataList.length,
        itemBuilder: (context, index) {
          HealthDataPoint data = dataList[index];
          return ListTile(
            title: Text("${data.typeString}: ${data.value}"),
            subtitle: Text("日期: ${data.dateFrom} - ${data.dateTo}"),
          );
        },
      ),
    );
  }
}
