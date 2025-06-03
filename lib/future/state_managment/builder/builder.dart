part of 'package:on_chain_wallet/future/state_managment/state_managment.dart';

typedef STATEBUILDER<T extends StateController> = Widget Function(T controller);
typedef ControllerBuilder<T extends StateController> = T Function();

class StateBuilder<T extends StateController> extends StatefulWidget {
  final STATEBUILDER<T> builder;
  final ControllerBuilder<T> controller;
  final String? stateId;
  final bool removable;
  final List<String> onRemoveIds;
  final String repositoryId;

  const StateBuilder({
    super.key,
    required this.controller,
    required this.builder,
    required this.repositoryId,
    this.onRemoveIds = const [],
    this.stateId,
    this.removable = true,
  });

  @override
  StateBuilderState<T> createState() => StateBuilderState<T>();
}

class StateBuilderState<T extends StateController>
    extends State<StateBuilder<T>> with SafeState {
  late final T stateController = widget.controller();
  void update() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    stateController._start();
    stateController.addListener(widget.stateId, update);
  }

  @override
  void dispose() {
    super.dispose();
    stateController.removeListener(widget.stateId, update);
    if (widget.removable) {
      r._remove(widget.repositoryId);
      for (final i in widget.onRemoveIds) {
        r._remove(i);
      }
    }
  }

  late RepositoryController r;

  @override
  void didChangeDependencies() {
    r = StateRepository.of(context);
    r._add(context, widget.repositoryId, stateController);
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(StateBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(stateController);
  }
}
