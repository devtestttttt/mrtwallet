import 'package:flutter/material.dart';

class APPAnimatedRemovableList extends StatefulWidget {
  const APPAnimatedRemovableList(
      {required this.itemBuilder,
      required this.length,
      required this.shrinkWrap,
      this.physics,
      super.key});
  final int length;
  final bool shrinkWrap;
  final Widget Function(BuildContext, int index, Animation<double>,
      [bool? inRemove]) itemBuilder;
  final ScrollPhysics? physics;
  @override
  State<APPAnimatedRemovableList> createState() => APPRemovableListState();
}

class APPRemovableListState extends State<APPAnimatedRemovableList> {
  final GlobalKey<SliverAnimatedListState> key = GlobalKey();
  void removeIndex(int index) {
    Widget builder(context, animation) {
      return widget.itemBuilder(context, index, animation, true);
    }

    key.currentState?.removeItem(index, builder);
  }

  // void insertAllItems(int index, int length) {
  //   key.currentState?.insertAllItems(index, length);
  // }

  @override
  Widget build(BuildContext context) {
    return SliverAnimatedList(
      key: key,
      itemBuilder: widget.itemBuilder,
      initialItemCount: widget.length,
    );
  }
}
