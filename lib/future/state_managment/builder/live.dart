part of 'package:on_chain_wallet/future/state_managment/state_managment.dart';

// class LiveWidget extends LiveStatelessWidget {
//   final Widget Function() builder;

//   const LiveWidget(this.builder, {super.name, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return builder();
//   }
// }

typedef STREAMBUILER<T> = Widget Function(BuildContext context, T value);

class StreamWidget<T> extends StatelessWidget {
  final StreamValue<T> value;
  final STREAMBUILER<T> builder;
  const StreamWidget({required this.value, required this.builder, super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
        stream: value.stream,
        initialData: value.value,
        builder: (context, snapshot) {
          return builder(context, snapshot.data as T);
        });
  }
}
