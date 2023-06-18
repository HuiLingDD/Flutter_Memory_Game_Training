import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_memory_game_training/constant.dart';
import 'package:flutter_memory_game_training/widgets/card.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key, required this.title});

  final String title;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  // 宣告List，回傳candidates index商數，再將20個圖片隨機打亂
  List<String> numList = List.generate(20, (index) => candidates[index ~/ 2])
    ..shuffle();
  // 宣告20個預設為false(背面)的List
  List<bool> isFrontList = List.generate(20, (index) => false);
  List<String> correctNumList = []; // 紀錄猜對圖片
  Map<String, dynamic> flippedCardInfo = {}; // 紀錄當前卡片翻出來的位置、圖片名稱
  bool isRunning = false; // 預設遊戲還沒開始
  final _controller = ConfettiController(); // 彩帶初始化
  final Stopwatch _stopwatch = Stopwatch(); // 碼錶初始化
  late Timer _timer;
  String _elapsedTime = '00:00:00';

  // 點擊卡片
  void onCardTap(int idx, String img) {
    List<bool> newIsFrontList = isFrontList;
    newIsFrontList[idx] = !newIsFrontList[idx];

    // 如果為空
    if (flippedCardInfo.isEmpty) {
      newIsFrontList[idx] = true; // 則將當前點的卡片翻為正面
      flippedCardInfo = {"idx": idx, "img": img}; // 將當前點的卡片位置和圖片名稱存入
    } else {
      // 判斷當前點的卡片和前一個點的卡片是否為相同位置的卡片
      if (idx == flippedCardInfo["idx"]) {
        newIsFrontList[idx] = false; // 設為背面
        flippedCardInfo = {}; // 清除紀錄
      } else {
        // 當前點的卡片內容和前一個點的卡片內容相同(猜對圖片)
        if (img == flippedCardInfo["img"]) {
          newIsFrontList[idx] = true; // 設為正面
          // 過2s再將猜對的圖片名稱放入correctNumList裡，再消掉卡片
          Future.delayed(Duration(seconds: 2), () {
            setState(() {
              correctNumList..add(img);
            });
          });
          flippedCardInfo = {}; // 清除紀錄
        } else {
          newIsFrontList[idx] = true; // 設為正面，讓使用者看一下卡片內容
          flippedCardInfo = {}; // 清除紀錄
          // 過2s再更新所有卡片為背面
          Future.delayed(Duration(seconds: 2), () {
            setState(() {
              isFrontList = List.generate(20, (index) => false);
            });
          });
        }
      }
    }
    setState(() {
      isFrontList = newIsFrontList;
    });
  }

  // 開始遊戲
  void startGame() {
    _controller.stop();
    _startStopwatch();
    // 將20個圖片隨機打亂
    numList = List.generate(20, (index) => candidates[index ~/ 2])..shuffle();
    setState(() {
      isRunning = true;
      numList = numList;
      isFrontList = List.generate(20, (index) => true); // 卡片翻正面讓使用者看
      correctNumList = [];
      flippedCardInfo = {};
    });
    // 等待3s後將卡片全部翻為背面
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        isFrontList = List.generate(20, (index) => false);
      });
    });
  }

  // 碼錶開始
  void _startStopwatch() {
    _stopwatch.start();
    // 每一毫秒更新時間
    _timer = Timer.periodic(Duration(milliseconds: 1), (timer) {
      setState(() {
        _elapsedTime =
            '${_stopwatch.elapsed.inHours.toString().padLeft(2, '0')}:'
            '${(_stopwatch.elapsed.inMinutes % 60).toString().padLeft(2, '0')}:'
            '${(_stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0')}';
      });
    });
  }

  // 碼表停止
  void _stopStopwatch() {
    _stopwatch.stop();
    _timer.cancel(); // 取消計時器
  }

  // 碼錶重置
  void _resetStopwatch() {
    _stopwatch.reset();
    _timer.cancel(); // 取消計時器
    setState(() {
      _elapsedTime = '00:00:00';
    });
  }

  void dispose() {
    _timer.cancel(); // 取消計時器
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 190, 172, 250),
          title: Text(
            widget.title,
          ),
          centerTitle: true,
        ),
        body: Stack(children: [
          // 碼錶
          Positioned(
              top: 52,
              left: 80,
              child: Icon(Icons.timer_sharp, size: 40, color: Colors.black)),
          Positioned(
              top: 50,
              left: 130,
              child: Text('$_elapsedTime',
                  style: TextStyle(fontSize: 40, color: Colors.black))),
          // 卡片
          Container(
              alignment: Alignment(0, 0), // 置中
              child: Container(
                alignment: Alignment.center,
                width: cardSize * 6,
                height: cardSize * 6,
                // 卡片超出版面時自動跳行
                child: Wrap(
                    // numList轉換map後取得map的index
                    children: numList
                        .asMap()
                        .map((idx, img) => MapEntry(
                            idx,
                            correctNumList.contains(img) // 若當前的卡片內容包含在猜對的內容裡
                                // 則清除卡片
                                ? Container(
                                    margin: EdgeInsets.all(4.0),
                                    alignment: Alignment.center,
                                    width: cardSize,
                                    height: cardSize)
                                // 否則顯示卡片
                                : FlipCard(
                                    img: img,
                                    isFront: isFrontList[idx], // 取得當前卡片位置正背面
                                    // 點擊時傳入卡片位置和內容
                                    onTap: () {
                                      onCardTap(idx, img);
                                    },
                                  )))
                        .values
                        .toList()),
              )),
          // 如果還沒開始遊戲
          if (!isRunning)
            start()
          // 如果過關
          else if (correctNumList.length == candidates.length)
            win()
        ]));
  }

  Widget start() {
    return GestureDetector(
        onTap: startGame, // 點擊開始遊戲
        child: Container(
            alignment: Alignment(0, 0),
            child: Container(
                alignment: Alignment.center,
                height: MediaQuery.of(context).size.height * 0.6,
                width: MediaQuery.of(context).size.width * 0.9,
                color: Colors.white,
                child: Text('請點擊進行遊戲',
                    style: TextStyle(fontSize: 40, color: Colors.grey)))));
  }

  Widget win() {
    _controller.play();
    _stopStopwatch();
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(alignment: Alignment.topCenter, color: Colors.white),
        Align(
            alignment: Alignment(0, -0.6),
            child: Text('花費時間:${_elapsedTime}',
                style: TextStyle(fontSize: 40, color: Colors.black))),
        Container(
          alignment: Alignment(0, 0), // 置中
          child: MaterialButton(
            onPressed: () {
              _resetStopwatch();
              startGame();
            },
            child: Text('再玩一次',
                style: TextStyle(fontSize: 40, color: Colors.white)),
            color: Color.fromARGB(255, 190, 172, 250),
            // 邊框設為圓角
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
          ),
        ),
        // 彩帶
        ConfettiWidget(
          confettiController: _controller,
          blastDirection: pi / 2, // 往下噴彩帶
          blastDirectionality: BlastDirectionality.explosive, // 發射所有方向
          colors: [
            Colors.purpleAccent,
            Colors.yellow,
            Colors.lightBlueAccent,
            Colors.greenAccent
          ],
        )
      ],
    );
  }
}
