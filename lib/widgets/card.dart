import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_memory_game_training/constant.dart';

// 卡片正反面
class FlipCard extends StatefulWidget {
  const FlipCard(
      {Key? key, required this.img, required this.isFront, required this.onTap})
      : super(key: key);
  final String img;
  final bool isFront;
  final Function? onTap;

  @override
  State<FlipCard> createState() => _FilpCardState();
}

class _FilpCardState extends State<FlipCard> {
  @override
  Widget build(BuildContext context) {
    Widget _transitionBuilder(Widget child, Animation<double> animation) {
      final anim = Tween(begin: pi, end: 0).animate(animation); // 翻轉180度
      return AnimatedBuilder(
          animation: anim,
          builder: (context, widget) {
            return Transform(
                transform: Matrix4.rotationY(anim.value.toDouble()), // 依y軸旋轉
                child: child,
                alignment: Alignment.center);
          });
    }

    return GestureDetector(
        onTap: () {
          widget.onTap?.call(); // onTap不為空時執行
        },
        // 正反面切換動畫
        child: AnimatedSwitcher(
            // 動畫執行時間
            duration: Duration(milliseconds: 1000),
            transitionBuilder: _transitionBuilder, // 自定義構建動畫
            // 如果是正面(true)顯示傳入的圖片，否則顯示背面圖片
            child: widget.isFront
                ? Card(
                    key: ValueKey(true),
                    img: widget.img,
                    color: Color.fromARGB(255, 95, 153, 252))
                : Card(
                    key: ValueKey(false),
                    img: "assets/images/11.png",
                    color: Color.fromARGB(255, 216, 197, 253))));
  }
}

// 卡片樣式
class Card extends StatelessWidget {
  const Card({Key? key, required this.img, required this.color})
      : super(key: key);
  final String img;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(4.0),
      key: key,
      alignment: Alignment.center,
      width: cardSize,
      height: cardSize,
      decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(image: AssetImage(img), fit: BoxFit.cover)),
    );
  }
}
