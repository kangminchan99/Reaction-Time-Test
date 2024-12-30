import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:reaction_rate/screen/leader_board_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Color _backgroundColor = Colors.blue;
  String _message = 'Tap to start';
  Timer? _timer;
  DateTime? _startTime;
  bool _isReady = false;
  final Random _random = Random();
  final List<int> _reactionTimes = []; // 반응 속도 기록

  void _startTest() {
    setState(() {
      _backgroundColor = Colors.red;
      _message = 'Wait for green';
      _isReady = false;
    });

    int delay = _random.nextInt(3000) + 2000; // 2~5초 랜덤 대기
    _timer = Timer(Duration(milliseconds: delay), () {
      setState(() {
        _backgroundColor = Colors.green;
        _message = 'Tap now!';
        _isReady = true;
        _startTime = DateTime.now();
      });
    });
  }

  void _handleTap() {
    if (_backgroundColor == Colors.blue) {
      // 초기 화면에서 탭
      _startTest();
    } else if (_backgroundColor == Colors.red) {
      // 너무 빨리 탭한 경우
      _showTooFastMessage();
    } else if (_backgroundColor == Colors.green && _isReady) {
      // 녹색일 때 탭
      int reactionTime = DateTime.now().difference(_startTime!).inMilliseconds;
      _storeReactionTime(reactionTime);
    }
  }

  void _showTooFastMessage() {
    setState(() {
      _backgroundColor = Colors.blue;
      _message = 'Too soon!\nTap to restart';
    });
    _timer?.cancel();
  }

  void _storeReactionTime(int reactionTime) async {
    _reactionTimes.add(reactionTime);

    if (_reactionTimes.length >= 5) {
      // 5번 기록 후 평균 계산 및 표시
      int averageTime =
          _reactionTimes.reduce((a, b) => a + b) ~/ _reactionTimes.length;

      // 평균 시간 저장
      await _saveAverageTime(averageTime);

      _showAverageReactionTime(averageTime);
      _reactionTimes.clear(); // 기록 초기화
    } else {
      // 반응 시간만 표시
      _showReactionTime(reactionTime);
    }
  }

  Future<void> _saveAverageTime(int averageTime) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> storedAverages =
        prefs.getStringList('averageTimes') ?? []; // 기존 저장된 데이터

    // 기존 데이터를 정수 리스트로 변환
    List<int> averages = storedAverages.map(int.parse).toList();

    if (averages.length < 10) {
      averages.add(averageTime);
    } else {
      // 가장 느린 기록과 새로운 평균 비교
      averages.sort(); // 오름차순 정렬
      if (averageTime < averages.last) {
        averages[averages.length - 1] = averageTime; // 가장 느린 값 교체
      }
    }

    // 내림차순 정렬 후 저장
    averages.sort((a, b) => a.compareTo(b));
    await prefs.setStringList(
        'averageTimes', averages.map((e) => e.toString()).toList());
  }

  void _showReactionTime(int reactionTime) {
    setState(() {
      _backgroundColor = Colors.blue;
      _message = 'Reaction time: $reactionTime ms\nClick to keep going';
    });
    _timer?.cancel();
  }

  void _showAverageReactionTime(int averageTime) {
    setState(() {
      _backgroundColor = Colors.blue;
      _message = 'Average reaction time: $averageTime ms\nTap to restart';
    });
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _backgroundColor == Colors.blue
          ? AppBar(
              backgroundColor: Colors.blue,
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LeaderBoardScreen()),
                    );
                  },
                  icon: const Icon(
                    Icons.leaderboard_outlined,
                    color: Colors.white,
                  ),
                )
              ],
            )
          : null,
      body: GestureDetector(
        onTap: _handleTap,
        child: Container(
          color: _backgroundColor,
          child: Center(
            child: Text(
              _message,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
