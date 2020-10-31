import 'dart:async';

import 'package:flutter/services.dart';

typedef Future<dynamic> MessageHandler(Map<String, dynamic> message);

class FlutterSiriActivity {
  const FlutterSiriActivity({
    @required this.title,
    @required this.key,
    this.contentDescription,
    this.suggestedInvocationPhrase,
    this.userInfo,
    this.persistentIdentifier,
    this.isEligibleForSearch = true,
    this.isEligibleForPrediction = true,
  })
      : assert(title != null),
        assert(key != null),
        super();

  final String title;
  final String key;
  final String contentDescription;
  final bool isEligibleForSearch;
  final bool isEligibleForPrediction;
  final String suggestedInvocationPhrase;
  final String persistentIdentifier;
  final Map<dynamic, dynamic> userInfo;

  Map<String, dynamic> asMap() {
    return {
      'title': this.title,
      'key': this.key,
      'userInfo': this.userInfo,
      'contentDescription': this.contentDescription,
      'isEligibleForSearch': this.isEligibleForSearch,
      'isEligibleForPrediction': this.isEligibleForPrediction,
      'suggestedInvocationPhrase': this.suggestedInvocationPhrase ?? "",
      'persistentIdentifier': this.persistentIdentifier,
    };
  }
}

class FlutterSiriSuggestions {
  FlutterSiriSuggestions._();

  /// Singleton of [FlutterSiriSuggestions].
  static final FlutterSiriSuggestions instance = FlutterSiriSuggestions._();

  MessageHandler _onLaunch;

  static const _channel = MethodChannel('flutter_siri_suggestions');

  Future<String> buildActivity(FlutterSiriActivity activity) async {
    return _channel.invokeMethod('becomeCurrent', activity.asMap());
  }

  // We could update this to accept a list
  Future<void> deleteByPersistentIdentifier(List<String> ids) async {
    return _channel.invokeMethod('deleteByPersistentIdentifier', ids);
  }

  Future<void> deleteAllSavedUserActivities() async {
    return _channel.invokeMethod('deleteAllSavedUserActivities');
  }

  void configure({MessageHandler onLaunch}) {
    _onLaunch = onLaunch;
    _channel.setMethodCallHandler(_handleMethod);
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "onLaunch":
        return _onLaunch(call.arguments.cast<String, dynamic>());
      default:
        throw UnsupportedError("Unrecognized JSON message");
    }
  }
}
