import 'dart:async';
import 'package:on_chain_wallet/app/models/models/typedef.dart';

mixin _LiveListenable {
  final Set<DynamicVoid> _noneIdsListeners = {};

  void addListener(DynamicVoid callBack) {
    _noneIdsListeners.add(callBack);
  }

  void removeListener(DynamicVoid callBack) {
    _noneIdsListeners.remove(callBack);
  }

  void notify() {
    for (final i in [..._noneIdsListeners]) {
      i();
    }
  }
}

class LiveListenable<T> with _LiveListenable {
  LiveListenable(T val) : _value = val;

  void dispose() {
    _noneIdsListeners.clear();
  }

  T _value;

  T get value {
    return _value;
  }

  T get valueSilent => _value;

  set value(T newValue) {
    if (_value == newValue) return;
    _value = newValue;
    notify();
  }
}

class StreamListenable<T> {
  T _value;
  StreamListenable(T val, {this.immutable = false}) : _value = val;
  final bool immutable;
  bool get isClosed => _controller.isClosed;

  late final StreamController<T> _controller =
      StreamController.broadcast(onCancel: () {}, onListen: () {});
  Stream<T> get stream => _controller.stream;

  T get value {
    return _value;
  }

  set value(T newValue) {
    assert(!isClosed, 'stream  closed.');
    assert(!immutable, 'data marked as immutable');
    if (_value == newValue || immutable) return;
    _value = newValue;
    if (_controller.hasListener && !isClosed) {
      _controller.add(newValue);
    }
  }

  set updateValue(T newValue) {
    assert(!isClosed, 'stream  closed.');
    assert(!immutable, 'data marked as immutable');
    if (immutable) return;
    _value = newValue;
    if (_controller.hasListener && !isClosed) {
      _controller.add(newValue);
    }
  }

  void notify() {
    assert(!isClosed, 'stream  closed.');
    if (_controller.hasListener && !isClosed) {
      _controller.add(_value);
    }
  }

  void dispose() {
    if (isClosed) return;
    _controller.close();
  }
}

class StreamValue<T> extends StreamListenable<T> {
  StreamValue(super.val);
  StreamValue.immutable(super.val) : super(immutable: true);
}

mixin StreamStateController {
  bool _closed = false;
  final StreamValue<void> notifier = StreamValue(null);
  Stream<void> get stream => notifier.stream;
  void notify() {
    if (_closed) return;
    notifier.notify();
  }

  void dispose() {
    if (_closed) return;
    _closed = true;
    notifier.dispose();
  }
}
