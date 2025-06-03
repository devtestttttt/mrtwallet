part of 'package:on_chain_wallet/future/state_managment/state_managment.dart';

// /// a Component that can track changes in a reactive variable
// mixin StatelessObserver on StatelessElement {
//   String? get name;
// //   void _update() {
// //     if (mounted) {
// //       scheduleMicrotask(markNeedsBuild);
// //     }
// //   }

// //   static Widget _sycronizedBuld(
// //       LiveNamedListener listener, Widget Function() builder) {
// //     LiveListenable.listener = listener;
// //     final build = builder();
// //     LiveListenable.listener = null;
// //     return build;
// //   }

// //   @override
// //   Widget build() {
// //     return _sycronizedBuld(
// //         LiveNamedListener(name: name, listener: _update), super.build);
// //   }
// // }

// class LiveElement extends StatelessElement with StatelessObserver {
//   @override
//   final String? name;
//   LiveElement(this.name, super.widget);
// }

// abstract class LiveStatelessWidget extends StatelessWidget {
//   final String? name;
//   const LiveStatelessWidget({this.name, super.key});
//   @override
//   StatelessElement createElement() => LiveElement(name, this);
// }
