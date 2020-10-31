package com.example.flutter_siri_suggestions

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class FlutterSiriSuggestionsPlugin: MethodCallHandler {
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "flutter_siri_suggestions")
      channel.setMethodCallHandler(FlutterSiriSuggestionsPlugin())
    }
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    // Android is not supported, it is an iOS-only plugin.
    // NOOP success.
    result.success(null)
  }
}
