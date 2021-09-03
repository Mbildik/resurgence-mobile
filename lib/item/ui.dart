import 'package:flutter/material.dart';
import 'package:resurgence/item/item.dart';

class ItemImage extends StatelessWidget {
  const ItemImage({
    Key key,
    @required this.item,
    this.height = 64.0,
    this.width = 64.0,
    this.border = 3.0,
    this.backgroundColor = const Color(0xffd6bd95),
  }) : super(key: key);

  final Item item;
  final double height;
  final double width;
  final double border;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        border: Border.all(color: item.quality.color(), width: border),
        borderRadius: BorderRadius.circular(8.0),
        color: backgroundColor,
      ),
      child: Image.network(item.image, height: height, width: width),
    );
  }
}
