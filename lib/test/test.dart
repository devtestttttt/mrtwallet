import 'package:flutter/material.dart';
import 'package:on_chain_wallet/future/state_managment/extension/extension.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SizedBox(
        width: context.mediaQuery.size.width,
        child: Column(
            spacing: 12,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: []),
      ),
    );
  }
}
