package com.example.poddle_nfc

import android.Manifest
import android.app.Activity
import android.content.Context
import android.nfc.NfcAdapter
import android.nfc.NfcManager
import android.nfc.Tag
import android.os.Build
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.concurrent.CopyOnWriteArrayList

const val PERMISSION_NFC: Int = 1007
/** PoddleNfcPlugin */
@RequiresApi(Build.VERSION_CODES.KITKAT)
class PoddleNfcPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, EventChannel.StreamHandler, NfcAdapter.ReaderCallback {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var methodChannel : MethodChannel

  private var nfcAdapter: NfcAdapter? = null
  private var nfcManager: NfcManager? = null
  private var activity: Activity? = null

  internal var eventSink: EventChannel.EventSink? = null
  private lateinit var eventChannel: EventChannel;
  private var nfcFlags = NfcAdapter.FLAG_READER_NFC_A or
          NfcAdapter.FLAG_READER_NFC_B or
          NfcAdapter.FLAG_READER_NFC_BARCODE or
          NfcAdapter.FLAG_READER_NFC_F or
          NfcAdapter.FLAG_READER_NFC_V

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "poddle_nfc")
    methodChannel.setMethodCallHandler(this)
    eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "poddle_nfc_stream")
    eventChannel.setStreamHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
//    if (call.method == "getPlatformVersion") {
//      result.success("Android ${android.os.Build.VERSION.RELEASE}")
//    } else {
//      result.notImplemented()
//    }

    require(activity != null) { "Plugin not ready yet" }
    val nfcAdapter by lazy {
      if (nfcAdapter == null) {
        result.error("404", "NFC Hardware not found", null)
      }
      nfcAdapter ?: error("NFC hardware not found")
    }

    when (call.method) {
      "NfcEnableReaderMode" ->
        nfcAdapter.startNFCReader()
      "NfcDisableReaderMode" ->
        nfcAdapter.stopNFCReader()
      "NfcStop" -> {
        listeners.removeAll { it !is NfcScanner }
        result.success(null)
      }

      "NfcRead" -> {
        listeners.add(NfcReader(result, call))
      }

      "NfcWrite" -> {
        listeners.add(NfcWriter(result, call))
      }
      "NfcAvailable" -> {
        when {
          this.nfcAdapter == null -> result.success("not_supported")
          nfcAdapter.isEnabled -> result.success("available")
          else -> result.success("disabled")
        }
      }
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel.setMethodCallHandler(null)
    eventChannel.setStreamHandler(null)
  }


  private fun NfcAdapter.startNFCReader() {
    listeners.add(NfcScanner(this@PoddleNfcPlugin))
    enableReaderMode(activity, this@PoddleNfcPlugin, nfcFlags, null)
  }


  private fun NfcAdapter.stopNFCReader() {
    disableReaderMode(activity)
    listeners.clear()
  }

  // handle discovered NDEF Tags
  override fun onTagDiscovered(tag: Tag): Unit = listeners.forEach { it.onTagDiscovered(tag) }


  @RequiresApi(Build.VERSION_CODES.M)
  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    val activity = binding.activity
    this.activity = activity

    nfcManager = activity.getSystemService(Context.NFC_SERVICE) as? NfcManager
    nfcAdapter = nfcManager?.defaultAdapter

    activity.requestPermissions(
            arrayOf(Manifest.permission.NFC),
            PERMISSION_NFC
    )

    nfcAdapter?.startNFCReader()
  }

  @RequiresApi(Build.VERSION_CODES.M)
  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding): Unit = onAttachedToActivity(binding)

  override fun onDetachedFromActivityForConfigChanges(): Unit = onDetachedFromActivity()

  override fun onDetachedFromActivity() {
    activity = null
  }

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    eventSink = events
  }

  override fun onCancel(arguments: Any?) {
    eventSink = null
  }


  companion object {
    internal val listeners = CopyOnWriteArrayList<NfcAdapter.ReaderCallback>()
  }
}
