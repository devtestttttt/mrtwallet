// import 'package:flutter/material.dart';
// import 'package:on_chain_wallet/app/constant/constant.dart';
// import 'package:on_chain_wallet/future/state_managment/state_managment.dart';
// import 'package:on_chain_wallet/future/wallet/start/pages/home_screen.dart';
// import 'package:on_chain_wallet/future/wallet/swaps/pages/widget/home.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> with SafeState<HomeScreen> {
//   int index = 0;

//   void onChangeIndex(int index) {
//     this.index = index;
//     updateState();
//     setState(() {});
//     print("changed $index");
//   }

//   @override
//   Widget build(BuildContext context) {
//     final wallet = context.wallet;

//     return StateBuilder(
//       removable: false,
//       controller: () => wallet,
//       repositoryId: StateConst.main,
//       builder: (controller) {
//         return Scaffold(
//           bottomNavigationBar: BottomNavigationBar(
//             currentIndex: index,
//             onTap: onChangeIndex,
//             // type: BottomNavigationBarType.shifting,
//             items: [
//               BottomNavigationBarItem(
//                   icon: Icon(Icons.wallet), label: 'wallet'),
//               BottomNavigationBarItem(
//                   icon: Icon(Icons.swap_horiz_rounded), label: 'swap'.tr),
//             ],
//           ),
//           body: IndexedStack(
//             index: index,
//             children: [WalletScreen(), SwapView()],
//           ),
//         );
//       },
//     );
//   }
// }
