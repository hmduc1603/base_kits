import 'dart:developer';

import 'package:rxdart/rxdart.dart';

class EventBus {
  static final EventBus _instance = EventBus._internal();
  EventBus._internal();
  factory EventBus() => _instance;

  PublishSubject<dynamic>? _pubSub;

  init() {
    _pubSub = PublishSubject<dynamic>();
  }

  void fire(dynamic value) {
    try {
      log("EventBus - Fire: $value");
      _pubSub!.add(value);
    } catch (e) {
      log(e.toString(), name: "EventBus");
    }
  }

  Stream<T> subscribe<T>() {
    return _pubSub!.asBroadcastStream().where((e) => e is T).map((e) => e as T);
  }
}
