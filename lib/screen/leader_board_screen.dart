import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeaderBoardScreen extends StatefulWidget {
  const LeaderBoardScreen({super.key});

  @override
  State<LeaderBoardScreen> createState() => _LeaderBoardScreenState();
}

class _LeaderBoardScreenState extends State<LeaderBoardScreen> {
  List<int> _averageTimes = [];

  @override
  void initState() {
    super.initState();
    _loadAverageTimes();
  }

  Future<void> _loadAverageTimes() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? storedAverages = prefs.getStringList('averageTimes');
    setState(() {
      _averageTimes = storedAverages?.map(int.parse).toList() ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Leaderboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Average Reaction Times:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ..._averageTimes.asMap().entries.map((entry) {
              int rank = entry.key + 1; // 순위는 인덱스 + 1
              int time = entry.value;
              return Text(
                '$rank. $time ms',
                style: const TextStyle(fontSize: 17),
              );
            }),
          ],
        ),
      ),
    );
  }
}
